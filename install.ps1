#Requires -Version 5.1

param(
    [string]$Only,
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
    "ZedIndustries.Zed",
    "DEVCOM.JetBrainsMonoNerdFont"
)

# Target under $HOME -> source under $RepoDir
$Links = [ordered]@{
    ".gitconfig"  = "home\.gitconfig"
    ".vimrc"      = "home\.vimrc"
}

$AppDataLinks = [ordered]@{
    "alacritty"   = "AppData\Roaming\alacritty"
}

$script:Linked    = 0
$script:Unchanged = 0
$script:Warnings  = 0
$script:Start     = Get-Date

# =============================================================================
# Logging
# =============================================================================

$Gutter = 11
$UseColor = $Host.UI.SupportsVirtualTerminal -and -not $env:NO_COLOR

function Emit {
    param([string]$Color, [string]$Verb, [string]$Message)
    $pad = $Verb.PadLeft($Gutter)
    if ($UseColor) {
        Write-Host "$Color$pad$([char]27)[0m $Message"
    } else {
        Write-Host "$pad $Message"
    }
}

function Banner { param([string]$Message)
    Write-Host ""
    Write-Host "dotfiles  $Message"
}
function Phase { param([string]$Name)
    Write-Host ""
    Write-Host $Name.PadLeft($Gutter)
}
function Say  { param([string]$Verb, [string]$Message) Emit "$([char]27)[32m" $Verb $Message }
function Note { param([string]$Verb, [string]$Message) Emit "$([char]27)[2m"  $Verb $Message }
function Warn { param([string]$Message)
    $script:Warnings++
    Emit "$([char]27)[33m" "Warning" $Message
}
function Fail { param([string]$Message)
    Emit "$([char]27)[31m" "Error" $Message
    exit 1
}
function VSay { param([string]$Verb, [string]$Message)
    if ($Verbose) { Note $Verb $Message }
}
function Cont { param([string]$Message) Write-Host "$("".PadLeft($Gutter)) $Message" }

function Tilde { param([string]$Path) $Path -replace [regex]::Escape($HOME), "~" }

function Plural { param([int]$N, [string]$Word)
    if ($N -eq 1) { "$N $Word" } else { "$N ${Word}s" }
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
        # checked by hand. `winget install` on an already-installed package
        # exits non-zero, hence the probe.
        winget list --id $id --exact --accept-source-agreements *> $null
        if ($LASTEXITCODE -eq 0) {
            VSay "Present" $id
            continue
        }

        if ($DryRun) {
            Note "Would run" "winget install $id"
            continue
        }

        winget install --id $id --exact --silent `
            --accept-package-agreements --accept-source-agreements *> $null
        if ($LASTEXITCODE -ne 0) {
            Warn "winget install $id failed ($LASTEXITCODE)"
        } else {
            Say "Installed" $id
        }
    }
}

# =============================================================================
# Symlinks
# =============================================================================

function Test-Symlink {
    param([string]$Path)
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return $false }
    return $item.LinkType -eq "SymbolicLink"
}

function Link-One {
    param([string]$Target, [string]$Source)

    if (-not (Test-Path -LiteralPath $Source)) {
        Warn "missing in repo: $Source"
        return
    }

    if ((Test-Symlink $Target) -and
        ((Get-Item -LiteralPath $Target -Force).Target -eq $Source)) {
        $script:Unchanged++
        VSay "Unchanged" (Tilde $Target)
        return
    }

    if (Test-Path -LiteralPath $Target) {
        $backup = Join-Path $HOME ".dotfiles-backup\$($script:Start.ToString('yyyyMMdd-HHmmss'))"
        if ($DryRun) {
            Note "Would back up" (Tilde $Target)
        } else {
            New-Item -ItemType Directory -Force -Path $backup | Out-Null
            Move-Item -LiteralPath $Target -Destination $backup -Force
            Say "Backed up" "$(Tilde $Target) -> $(Tilde $backup)"
        }
    }

    if ($DryRun) {
        Note "Would link" (Tilde $Target)
        return
    }

    $parent = Split-Path -Parent $Target
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    try {
        New-Item -ItemType SymbolicLink -Force -Path $Target -Target $Source | Out-Null
        $script:Linked++
        Say "Linked" (Tilde $Target)
    } catch {
        # Symlinks need Developer Mode or an elevated shell.
        Warn "could not link $(Tilde $Target): $($_.Exception.Message)"
    }
}

function Link-Dotfiles {
    Phase "Linking"

    foreach ($target in $Links.Keys) {
        Link-One (Join-Path $HOME $target) (Join-Path $RepoDir $Links[$target])
    }
    foreach ($target in $AppDataLinks.Keys) {
        Link-One (Join-Path $env:APPDATA $target) (Join-Path $RepoDir $AppDataLinks[$target])
    }

    if ($script:Linked -eq 0) {
        Note "Unchanged" "$(Plural $script:Unchanged 'file') already linked"
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
    Say "Wrote" "$(Tilde $local)"
}

# =============================================================================
# CLI
# =============================================================================

function Show-Usage {
    @"
Usage: install.ps1 [options]

    -Only PHASE     run one phase: packages links git
    -DryRun         print what would run without running it
    -Verbose        show unchanged items
    -Help           print this message

"@ | Write-Host
}

function Main {
    if ($Help) { Show-Usage; return }

    $phases = @("packages", "links", "git")
    if ($Only -and $phases -notcontains $Only) {
        Fail "-Only must be one of: $($phases -join ', ')"
    }

    Banner "windows - $(Tilde $RepoDir)$(if ($DryRun) { ' - dry run' })"

    if (-not $Only -or $Only -eq "packages") { Install-Packages }
    if (-not $Only -or $Only -eq "links")    { Link-Dotfiles }
    if (-not $Only -or $Only -eq "git")      { Set-GitLocal }

    $elapsed = [int]((Get-Date) - $script:Start).TotalSeconds
    $parts = "$script:Linked linked - $script:Unchanged unchanged"
    if ($script:Warnings -gt 0) { $parts += " - $(Plural $script:Warnings 'warning')" }

    Write-Host ""
    Say "Finished" "$parts - ${elapsed}s"
    Cont "restart your shell for PATH changes to apply"
}

Main
