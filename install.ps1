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

# Windows PowerShell 5.1 turns redirected native stderr into error records.
# Use Continue only around native calls, then restore Stop for PowerShell work.
# Native command success is determined by $LASTEXITCODE, not stderr output.

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
    ".gitconfig"     = "home\.gitconfig"
    ".vimrc"         = "home\.vimrc"
    ".agents\skills" = "home\.agents\skills"
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
#
$VSCodeConfigDir = Join-Path $RepoDir "home\.config\vscode"
$VSCodeUserDir   = Join-Path $env:APPDATA "Code\User"
$ZedConfigDir    = Join-Path $RepoDir "home\.config\zed"
$ZedUserDir      = Join-Path $env:APPDATA "Zed"

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
        # Probe first so already-installed packages do not generate errors.
        $previousErrorAction = $ErrorActionPreference
        try {
            $ErrorActionPreference = "Continue"
            winget list `
                --id $id `
                --exact `
                --accept-source-agreements *> $null
        } finally {
            $ErrorActionPreference = $previousErrorAction
        }

        if ($LASTEXITCODE -eq 0) {
            VSay "Present" $id
            continue
        }

        if ($DryRun) {
            Note "Would run" "winget install $id"
            continue
        }

        $previousErrorAction = $ErrorActionPreference
        try {
            $ErrorActionPreference = "Continue"
            winget install `
                --id $id `
                --exact `
                --silent `
                --accept-package-agreements `
                --accept-source-agreements *> $null
        } finally {
            $ErrorActionPreference = $previousErrorAction
        }

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
    $previousErrorAction = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & git --no-pager diff `
            --no-index `
            -- `
            $Source `
            $Target
    } finally {
        $ErrorActionPreference = $previousErrorAction
    }

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
    $previousErrorAction = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $current = git config --file $local core.autocrlf 2>$null
    } finally {
        $ErrorActionPreference = $previousErrorAction
    }

    if ($current -eq "input") {
        VSay "Current" "core.autocrlf"
        return
    }

    if ($DryRun) {
        Note "Would set" "core.autocrlf=input in $(Tilde $local)"
        return
    }

    $previousErrorAction = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        git config --file $local core.autocrlf input
    } finally {
        $ErrorActionPreference = $previousErrorAction
    }

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

function Get-VSCodeExtensions {
    $previousErrorAction = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $extensions = @(& code --list-extensions 2>$null)
    } finally {
        $ErrorActionPreference = $previousErrorAction
    }

    return @(
        $extensions |
            ForEach-Object {
                $_.Trim()
            } |
            Where-Object {
                $_
            }
    )
}

function Install-VSCodeExtensions {
    param([string]$Path)

    $extensions = @(Get-ExtensionList $Path)

    if ($extensions.Count -eq 0) {
        return
    }

    # Listing extensions writes VS Code logs, so avoid code calls in dry-run.
    $installed = @()
    if (-not $DryRun) {
        $installed = @(Get-VSCodeExtensions)
    }

    foreach ($extension in $extensions) {
        if ($installed -contains $extension) {
            VSay "Present" $extension
            continue
        }

        if ($DryRun) {
            Note "Would install" $extension
            continue
        }

        $previousErrorAction = $ErrorActionPreference
        try {
            $ErrorActionPreference = "Continue"
            & code --install-extension $extension *> $null
        } finally {
            $ErrorActionPreference = $previousErrorAction
        }

        if ($LASTEXITCODE -ne 0) {
            Warn "could not install $extension"
        } else {
            Say "Installed" $extension
        }
    }
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

    $settings = Join-Path $VSCodeConfigDir "settings.json"

    if (Test-Path -LiteralPath $settings) {
        Link-One `
            (Join-Path $VSCodeUserDir "settings.json") `
            $settings
    }

    $keybindings = Join-Path $VSCodeConfigDir "keybindings.json"

    if (Test-Path -LiteralPath $keybindings) {
        Link-One `
            (Join-Path $VSCodeUserDir "keybindings.json") `
            $keybindings
    }

    Install-VSCodeExtensions `
        (Join-Path $VSCodeConfigDir "extensions.txt")
}

# =============================================================================
# Zed
# =============================================================================

function Install-Zed {
    Phase "Zed"

    foreach ($file in @("settings.json", "keymap.json")) {
        Link-One `
            (Join-Path $ZedUserDir $file) `
            (Join-Path $ZedConfigDir $file)
    }
}

# =============================================================================
# CLI
# =============================================================================

function Show-Usage {
    @"
Usage: install.ps1 [options]

    -Only PHASE     run one phase: packages links git vscode zed
    -OnConflict MODE  prompt (default), overwrite, backup, capture, or skip
                      backup preserves local content in an adjacent .backup file
                      capture updates the repo from local content without a backup
    -DryRun         print what would run without running it
    -Verbose        show unchanged items
    -Help           print this message

Shared agent skills:

    Links home/.agents/skills/ to $HOME/.agents/skills/ during the links phase.
    Falls back to copying when symlinks are unavailable.

Portable VS Code configuration:

    home/.config/vscode/
        settings.json
        keybindings.json
        extensions.txt

Portable Zed configuration:

    home/.config/zed/
        settings.json
        keymap.json

Examples:

    .\install.ps1
    .\install.ps1 -DryRun
    .\install.ps1 -Verbose
    .\install.ps1 -Only vscode
    .\install.ps1 -Only zed
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
        "vscode",
        "zed"
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

    if (-not $Only -or $Only -eq "zed") {
        Install-Zed
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
