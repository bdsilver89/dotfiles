#Requires -Version 5.1

param(
    [string]$Only,
    [ValidateSet('prompt', 'overwrite', 'backup', 'capture', 'skip')]
    [string]$OnConflict = 'prompt',
    [switch]$DryRun,
    [switch]$Verbose,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# =============================================================================
# Globals
# =============================================================================

$RepoDir = Split-Path -Parent $PSCommandPath

$Packages = @(
    "Alacritty.Alacritty",
    "Microsoft.VisualStudioCode",
    "Microsoft.PowerShell",
    "ZedIndustries.Zed",
    "DEVCOM.JetBrainsMonoNerdFont"
)

# Target under $HOME -> source under $RepoDir
$Links = [ordered]@{
    ".gitconfig" = "home\.gitconfig"
    ".vimrc"     = "home\.vimrc"
}

# Target under %APPDATA% -> portable source under $RepoDir
$AppDataLinks = [ordered]@{
    "alacritty" = "home\.config\alacritty"
}

# Portable VS Code configuration:
#
# home/.config/vscode/
#   settings.json
#   keybindings.json
#   extensions.txt
#   profiles/
#     cpp/
#       settings.json
#       extensions.txt
#     java/
#       settings.json
#       extensions.txt
#     python/
#       settings.json
#       extensions.txt
#     rust/
#       settings.json
#       extensions.txt
#
$VSCodeConfigDir = Join-Path $RepoDir "home\.config\vscode"
$VSCodeUserDir   = Join-Path $env:APPDATA "Code\User"

$script:Linked    = 0
$script:Copied    = 0
$script:Unchanged = 0
$script:Warnings  = 0
$script:Start     = Get-Date

# =============================================================================
# Logging
# =============================================================================

$Gutter = 11
$UseColor = $Host.UI.SupportsVirtualTerminal -and -not $env:NO_COLOR

function Emit {
    param(
        [string]$Color,
        [string]$Verb,
        [string]$Message
    )

    $pad = $Verb.PadLeft($Gutter)

    if ($UseColor) {
        Write-Host "$Color$pad$([char]27)[0m $Message"
    } else {
        Write-Host "$pad $Message"
    }
}

function Banner {
    param([string]$Message)

    Write-Host ""
    Write-Host "dotfiles  $Message"
}

function Phase {
    param([string]$Name)

    Write-Host ""
    Write-Host $Name.PadLeft($Gutter)
}

function Say {
    param(
        [string]$Verb,
        [string]$Message
    )

    Emit "$([char]27)[32m" $Verb $Message
}

function Note {
    param(
        [string]$Verb,
        [string]$Message
    )

    Emit "$([char]27)[2m" $Verb $Message
}

function Warn {
    param([string]$Message)

    $script:Warnings++
    Emit "$([char]27)[33m" "Warning" $Message
}

function Fail {
    param([string]$Message)

    Emit "$([char]27)[31m" "Error" $Message
    exit 1
}

function VSay {
    param(
        [string]$Verb,
        [string]$Message
    )

    if ($Verbose) {
        Note $Verb $Message
    }
}

function Cont {
    param([string]$Message)

    Write-Host ("{0} {1}" -f "".PadLeft($Gutter), $Message)
}

function Tilde {
    param([string]$Path)

    $Path -replace [regex]::Escape($HOME), "~"
}

function Plural {
    param(
        [int]$N,
        [string]$Word
    )

    if ($N -eq 1) {
        "$N $Word"
    } else {
        "$N ${Word}s"
    }
}

# =============================================================================
# Packages
# =============================================================================

function Install-Packages {
    Phase "Packages"

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Fail "winget not found; install App Installer from the Microsoft Store"
    }

    foreach ($id in $Packages) {
        # Native commands ignore $ErrorActionPreference, so exit codes are
        # checked by hand. Probe first so already-installed packages do not
        # generate errors.
        winget list `
            --id $id `
            --exact `
            --accept-source-agreements *> $null

        if ($LASTEXITCODE -eq 0) {
            VSay "Present" $id
            continue
        }

        if ($DryRun) {
            Note "Would run" "winget install $id"
            continue
        }

        winget install `
            --id $id `
            --exact `
            --silent `
            --accept-package-agreements `
            --accept-source-agreements *> $null

        if ($LASTEXITCODE -ne 0) {
            Warn "winget install $id failed ($LASTEXITCODE)"
        } else {
            Say "Installed" $id
        }
    }
}

# =============================================================================
# File comparison
# =============================================================================

function Test-Symlink {
    param([string]$Path)

    $item = Get-Item `
        -LiteralPath $Path `
        -Force `
        -ErrorAction SilentlyContinue

    if (-not $item) {
        return $false
    }

    return $item.LinkType -eq "SymbolicLink"
}

function Test-SameFile {
    param(
        [string]$Left,
        [string]$Right
    )

    if (-not (Test-Path -LiteralPath $Left -PathType Leaf)) {
        return $false
    }

    if (-not (Test-Path -LiteralPath $Right -PathType Leaf)) {
        return $false
    }

    $leftHash = (
        Get-FileHash `
            -LiteralPath $Left `
            -Algorithm SHA256
    ).Hash

    $rightHash = (
        Get-FileHash `
            -LiteralPath $Right `
            -Algorithm SHA256
    ).Hash

    return $leftHash -eq $rightHash
}

function Get-RelativeFiles {
    param([string]$Root)

    $resolved = (Resolve-Path -LiteralPath $Root).Path

    return @(
        Get-ChildItem `
            -LiteralPath $resolved `
            -File `
            -Recurse |
            ForEach-Object {
                $_.FullName.Substring($resolved.Length).TrimStart('\', '/')
            } |
            Sort-Object
    )
}

function Test-SameDirectory {
    param(
        [string]$Left,
        [string]$Right
    )

    if (-not (Test-Path -LiteralPath $Left -PathType Container)) {
        return $false
    }

    if (-not (Test-Path -LiteralPath $Right -PathType Container)) {
        return $false
    }

    $leftRoot  = (Resolve-Path -LiteralPath $Left).Path
    $rightRoot = (Resolve-Path -LiteralPath $Right).Path

    $leftFiles  = @(Get-RelativeFiles $leftRoot)
    $rightFiles = @(Get-RelativeFiles $rightRoot)

    if (Compare-Object $leftFiles $rightFiles) {
        return $false
    }

    foreach ($relative in $leftFiles) {
        $leftFile  = Join-Path $leftRoot $relative
        $rightFile = Join-Path $rightRoot $relative

        if (-not (Test-SameFile $leftFile $rightFile)) {
            return $false
        }
    }

    return $true
}

function Test-SameContent {
    param(
        [string]$Left,
        [string]$Right
    )

    $leftItem = Get-Item `
        -LiteralPath $Left `
        -Force `
        -ErrorAction SilentlyContinue

    $rightItem = Get-Item `
        -LiteralPath $Right `
        -Force `
        -ErrorAction SilentlyContinue

    if (-not $leftItem -or -not $rightItem) {
        return $false
    }

    if ($leftItem.PSIsContainer -ne $rightItem.PSIsContainer) {
        return $false
    }

    if ($leftItem.PSIsContainer) {
        return Test-SameDirectory $Left $Right
    }

    return Test-SameFile $Left $Right
}

# =============================================================================
# Diff
# =============================================================================

function Show-Diff {
    param(
        [string]$Source,
        [string]$Target
    )

    Note "Different" (Tilde $Target)

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Cont "git not found; cannot show diff"
        return
    }

    Write-Host ""

    # git diff --no-index supports both files and directory trees.
    & git --no-pager diff `
        --no-index `
        -- `
        $Source `
        $Target

    # git diff returns:
    #   0 = identical
    #   1 = differences
    #  >1 = actual error
    if ($LASTEXITCODE -gt 1) {
        Warn "could not diff $(Tilde $Target)"
    }
}

# =============================================================================
# Links / copy fallback
# =============================================================================

function Copy-One {
    param(
        [string]$Target,
        [string]$Source
    )

    $parent = Split-Path -Parent $Target

    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item `
            -ItemType Directory `
            -Force `
            -Path $parent | Out-Null
    }

    Copy-Item `
        -LiteralPath $Source `
        -Destination $Target `
        -Recurse `
        -Force

    $script:Copied++
    Say "Copied" (Tilde $Target)
}

function Install-LinkOrCopy {
    param(
        [string]$Target,
        [string]$Source
    )

    $parent = Split-Path -Parent $Target

    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item `
            -ItemType Directory `
            -Force `
            -Path $parent | Out-Null
    }

    try {
        New-Item `
            -ItemType SymbolicLink `
            -Path $Target `
            -Target $Source `
            -ErrorAction Stop | Out-Null

        $script:Linked++
        Say "Linked" (Tilde $Target)
    } catch {
        VSay "Fallback" "symlink unavailable for $(Tilde $Target)"
        Copy-One $Target $Source
    }
}

function Link-One {
    param(
        [string]$Target,
        [string]$Source
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        Warn "missing in repo: $Source"
        return
    }

    # Already a symlink.
    if (Test-Symlink $Target) {
        $item = Get-Item -LiteralPath $Target -Force

        if ($item.Target -eq $Source) {
            $script:Unchanged++
            VSay "Unchanged" (Tilde $Target)
            return
        }

        Warn "$(Tilde $Target) links to unexpected target: $($item.Target)"
        return
    }

    # Existing regular file/directory.
    if (Test-Path -LiteralPath $Target) {
        if (Test-SameContent $Source $Target) {
            $script:Unchanged++
            VSay "Unchanged" "$(Tilde $Target) (copy)"
            return
        }

        Resolve-LinkConflict $Target $Source
        return
    }

    # Missing target.
    if ($DryRun) {
        Note "Would link" (Tilde $Target)
        return
    }

    Install-LinkOrCopy $Target $Source
}

function Resolve-LinkConflict {
    param(
        [string]$Target,
        [string]$Source
    )

    if ($DryRun) {
        Note "Conflict" "$(Tilde $Target) ($OnConflict; no changes)"
        return
    }

    $action = $OnConflict
    while ($action -eq 'prompt') {
        Note "Conflict" (Tilde $Target)
        Cont "Choose which version to keep."
        try {
            $choice = Read-Host '[o] Overwrite local / [b] Backup local and replace / [u] Update repo from local / [d] Diff / [s] Skip (default)'
        } catch {
            Warn "cannot prompt; skipping $(Tilde $Target). Use -OnConflict for unattended runs."
            return
        }

        switch ($choice.Trim().ToLowerInvariant()) {
            'o' { $action = 'overwrite' }
            'b' { $action = 'backup' }
            'u' { $action = 'capture' }
            'd' {
                Cont "Diff: - repo content, + local content"
                Show-Diff $Source $Target | Out-Host
            }
            's' { $action = 'skip' }
            ''  { $action = 'skip' }
            default { Cont "Choose o, b, u, d, or s." }
        }
    }

    if ($action -eq 'skip') {
        Warn "skipped $(Tilde $Target)"
        return
    }

    if ($action -eq 'capture') {
        # Reverse the copy direction; Git manages the repo version.
        # Always copy: linking the repo to a machine-local file is not portable.
        $local = $Target
        $Target = $Source
        $Source = $local
    }

    # Only replace ordinary files/directories, never traverse a junction or
    # another reparse point. Unexpected symlinks are handled by Link-One.
    $item = Get-Item -LiteralPath $Target -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Warn "refusing to replace reparse point: $(Tilde $Target)"
        return
    }

    $targetPath = $item.FullName
    $sourceItem = Get-Item -LiteralPath $Source -Force
    $sourcePath = $sourceItem.FullName
    if ($sourcePath -eq $targetPath -or
        $sourcePath.StartsWith($targetPath.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
        Warn "refusing to replace a directory containing the repo source: $(Tilde $Target)"
        return
    }

    if ($action -eq 'capture') {
        # Replace directory trees rather than merging stale repo files into
        # the captured version. Paths above are resolved and checked first.
        if ($targetPath.StartsWith($sourcePath.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
            Warn "refusing to copy a directory into itself: $(Tilde $Source)"
            return
        }
        if ($item.PSIsContainer -or $sourceItem.PSIsContainer) {
            Remove-Item -LiteralPath $targetPath -Recurse -Force
        }
        Copy-One $targetPath $Source
        return
    }

    # Move aside first so a failed installation preserves the original.
    # Number backups instead of overwriting an earlier backup.
    $backup = "$targetPath.backup"
    $suffix = 0
    while (Get-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue) {
        $suffix++
        $backup = "$targetPath.backup.$suffix"
    }
    Move-Item -LiteralPath $targetPath -Destination $backup
    try {
        Install-LinkOrCopy $targetPath $Source
    } catch {
        # A partial copy may exist. Keep both it and the original for recovery.
        Warn "replacement failed; original preserved at $(Tilde $backup)"
        throw
    }

    if ($action -eq 'backup') {
        Say "Backed up" (Tilde $backup)
    } else {
        # The backup is the exact adjacent path created above, not a glob.
        if ((Split-Path -Parent $backup) -ne (Split-Path -Parent $targetPath)) {
            throw "Unexpected backup location: $backup"
        }
        Remove-Item -LiteralPath $backup -Recurse -Force
    }
}

function Link-Dotfiles {
    Phase "Linking"

    foreach ($target in $Links.Keys) {
        Link-One `
            (Join-Path $HOME $target) `
            (Join-Path $RepoDir $Links[$target])
    }

    foreach ($target in $AppDataLinks.Keys) {
        Link-One `
            (Join-Path $env:APPDATA $target) `
            (Join-Path $RepoDir $AppDataLinks[$target])
    }
}

# =============================================================================
# Git
# =============================================================================

# Replaces the autocrlf conditional that lived in dot_gitconfig.tmpl;
# ~/.gitconfig already includes ~/.gitconfig.local.
function Set-GitLocal {
    Phase "Git"

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Warn "git not found, skipping"
        return
    }

    $local = Join-Path $HOME ".gitconfig.local"
    $current = git config --file $local core.autocrlf 2>$null

    if ($current -eq "input") {
        VSay "Current" "core.autocrlf"
        return
    }

    if ($DryRun) {
        Note "Would set" "core.autocrlf=input in $(Tilde $local)"
        return
    }

    git config --file $local core.autocrlf input

    if ($LASTEXITCODE -ne 0) {
        Warn "could not write $(Tilde $local)"
        return
    }

    Say "Wrote" "$(Tilde $local)"
}

# =============================================================================
# VS Code helpers
# =============================================================================

function Get-ExtensionList {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return @()
    }

    return @(
        Get-Content -LiteralPath $Path |
            ForEach-Object {
                $_.Trim()
            } |
            Where-Object {
                $_ -and -not $_.StartsWith("#")
            }
    )
}

function Get-VSCodeProfiles {
    $profilesDir = Join-Path $VSCodeConfigDir "profiles"

    if (-not (Test-Path -LiteralPath $profilesDir)) {
        return @()
    }

    return @(
        Get-ChildItem `
            -LiteralPath $profilesDir `
            -Directory |
            Sort-Object Name
    )
}

function Get-VSCodeExtensions {
    param([string]$Profile)

    $args = @("--list-extensions")

    if ($Profile) {
        $args += @(
            "--profile",
            $Profile
        )
    }

    return @(
        & code @args 2>$null |
            ForEach-Object {
                $_.Trim()
            } |
            Where-Object {
                $_
            }
    )
}

function Install-VSCodeExtensions {
    param(
        [string]$Path,
        [string]$Profile
    )

    $extensions = @(Get-ExtensionList $Path)

    if ($extensions.Count -eq 0) {
        return
    }

    $installed = @(Get-VSCodeExtensions $Profile)

    foreach ($extension in $extensions) {
        $label = $extension

        if ($Profile) {
            $label += " [$Profile]"
        }

        if ($installed -contains $extension) {
            VSay "Present" $label
            continue
        }

        if ($DryRun) {
            Note "Would install" $label
            continue
        }

        $args = @(
            "--install-extension",
            $extension
        )

        if ($Profile) {
            $args += @(
                "--profile",
                $Profile
            )
        }

        & code @args *> $null

        if ($LASTEXITCODE -ne 0) {
            Warn "could not install $label"
        } else {
            Say "Installed" $label
        }
    }
}

# =============================================================================
# VS Code profile settings
# =============================================================================

function Get-VSCodeProfileEntries {
    $profilesFile = Join-Path $VSCodeUserDir "profiles\profiles.json"

    if (-not (Test-Path -LiteralPath $profilesFile)) {
        return @()
    }

    try {
        $profiles = Get-Content `
            -LiteralPath $profilesFile `
            -Raw |
            ConvertFrom-Json

        return @($profiles.profiles)
    } catch {
        Warn "could not read VS Code profiles: $profilesFile"
        return @()
    }
}

function Get-VSCodeProfileId {
    param([string]$Name)

    $profiles = @(Get-VSCodeProfileEntries)

    foreach ($profile in $profiles) {
        if ($profile.name -eq $Name) {
            return $profile.location
        }
    }

    return $null
}

function Ensure-VSCodeProfile {
    param(
        [string]$Name,
        [string]$Path
    )

    $profileId = Get-VSCodeProfileId $Name

    if ($profileId) {
        return $profileId
    }

    # Installing an extension with --profile causes VS Code to create the
    # profile if it does not already exist.
    $extensions = @(Get-ExtensionList (Join-Path $Path "extensions.txt"))

    if ($extensions.Count -gt 0) {
        if ($DryRun) {
            Note "Would create" "VS Code profile $Name"
            return $null
        }

        & code `
            --profile $Name `
            --install-extension $extensions[0] *> $null

        if ($LASTEXITCODE -ne 0) {
            Warn "could not create VS Code profile $Name"
            return $null
        }
    } else {
        # There is no dedicated `code --create-profile` command. A profile with
        # no extensions cannot be reliably created through the CLI alone.
        Warn "profile $Name has no extensions; cannot create it through code CLI"
        return $null
    }

    return Get-VSCodeProfileId $Name
}

function Install-VSCodeProfile {
    param(
        [string]$Name,
        [string]$Path
    )

    VSay "Profile" $Name

    # Install profile-specific extensions. Passing --profile causes VS Code
    # to create the named profile when necessary.
    Install-VSCodeExtensions `
        (Join-Path $Path "extensions.txt") `
        $Name

    $settings = Join-Path $Path "settings.json"

    if (-not (Test-Path -LiteralPath $settings)) {
        return
    }

    $profileId = Get-VSCodeProfileId $Name

    if (-not $profileId) {
        $profileId = Ensure-VSCodeProfile $Name $Path
    }

    if (-not $profileId) {
        Warn "could not determine VS Code profile ID for $Name"
        return
    }

    # VS Code stores named profile settings under:
    #
    #   %APPDATA%\Code\User\profiles\<profile-id>\settings.json
    #
    # Keep that implementation detail here so the repository can retain the
    # portable representation:
    #
    #   home/.config/vscode/profiles/<name>/settings.json
    #
    $profileId = Split-Path $profileId -Leaf

    $profileDir = Join-Path $VSCodeUserDir "profiles\$profileId"
    $target     = Join-Path $profileDir "settings.json"

    Link-One $target $settings
}

# =============================================================================
# VS Code
# =============================================================================

function Install-VSCode {
    Phase "VS Code"

    if (-not (Test-Path -LiteralPath $VSCodeConfigDir)) {
        Warn "VS Code config not found: $VSCodeConfigDir"
        return
    }

    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Warn "code not found, skipping"
        return
    }

    # -------------------------------------------------------------------------
    # Default profile settings
    # -------------------------------------------------------------------------

    $settings = Join-Path $VSCodeConfigDir "settings.json"

    if (Test-Path -LiteralPath $settings) {
        Link-One `
            (Join-Path $VSCodeUserDir "settings.json") `
            $settings
    }

    # -------------------------------------------------------------------------
    # Default profile keybindings
    # -------------------------------------------------------------------------

    $keybindings = Join-Path $VSCodeConfigDir "keybindings.json"

    if (Test-Path -LiteralPath $keybindings) {
        Link-One `
            (Join-Path $VSCodeUserDir "keybindings.json") `
            $keybindings
    }

    # -------------------------------------------------------------------------
    # Default profile extensions
    # -------------------------------------------------------------------------

    Install-VSCodeExtensions `
        (Join-Path $VSCodeConfigDir "extensions.txt")

    # -------------------------------------------------------------------------
    # Named profiles
    #
    # Profiles are discovered automatically from:
    #
    #   home/.config/vscode/profiles/<name>/
    #
    # Each profile may contain:
    #
    #   settings.json
    #   extensions.txt
    # -------------------------------------------------------------------------

    foreach ($profile in Get-VSCodeProfiles) {
        Install-VSCodeProfile `
            $profile.Name `
            $profile.FullName
    }
}

# =============================================================================
# CLI
# =============================================================================

function Show-Usage {
    @"
Usage: install.ps1 [options]

    -Only PHASE     run one phase: packages links git vscode
    -OnConflict MODE  prompt (default), overwrite, backup, capture, or skip
                      backup preserves local content in an adjacent .backup file
                      capture updates the repo from local content without a backup
    -DryRun         print what would run without running it
    -Verbose        show unchanged items
    -Help           print this message

Portable VS Code configuration:

    home/.config/vscode/
        settings.json
        keybindings.json
        extensions.txt
        profiles/
            <profile>/
                settings.json
                extensions.txt

Examples:

    .\install.ps1
    .\install.ps1 -DryRun
    .\install.ps1 -Verbose
    .\install.ps1 -Only vscode
    .\install.ps1 -Only vscode -OnConflict backup
    .\install.ps1 -Only vscode -DryRun -Verbose

"@ | Write-Host
}

function Main {
    if ($Help) {
        Show-Usage
        return
    }

    $phases = @(
        "packages",
        "links",
        "git",
        "vscode"
    )

    if ($Only -and $phases -notcontains $Only) {
        Fail "-Only must be one of: $($phases -join ', ')"
    }

    Banner "windows - $(Tilde $RepoDir)$(if ($DryRun) { ' - dry run' })"

    if (-not $Only -or $Only -eq "packages") {
        Install-Packages
    }

    if (-not $Only -or $Only -eq "links") {
        Link-Dotfiles
    }

    if (-not $Only -or $Only -eq "git") {
        Set-GitLocal
    }

    if (-not $Only -or $Only -eq "vscode") {
        Install-VSCode
    }

    $elapsed = [int]((Get-Date) - $script:Start).TotalSeconds

    $parts = @(
        "$(Plural $script:Linked 'link')"
        "$(Plural $script:Copied 'copy')"
        "$(Plural $script:Unchanged 'unchanged item')"
    ) -join " - "

    if ($script:Warnings -gt 0) {
        $parts += " - $(Plural $script:Warnings 'warning')"
    }

    Write-Host ""
    Say "Finished" "$parts - ${elapsed}s"
    Cont "restart your shell for PATH changes to apply"
}

Main
