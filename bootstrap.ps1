param(
  [switch]$Update = $false,
  [switch]$Winget = $false,
  [switch]$All = $false,
  [switch]$UseSymlinks = $false,
  [switch]$Copy = $false,
  [switch]$DryRun = $false,
  [string[]]$Apps = @(),
  [switch]$Help = $false
)

# Files are linked by default (hardlink first, symlink fallback) so live edits
# round-trip into the repo. Pass -Copy to snapshot-copy instead.

# =============================================================================
# Dotfiles Bootstrap Script for Windows
# Mirrors the structure of bootstrap.sh for Linux/macOS
# =============================================================================

$DotfilesDir = $PSScriptRoot
$ProfileDir = Split-Path -parent $profile

# =============================================================================
# Logging Utilities
# =============================================================================

function Title {
  param([string]$msg)
  Write-Host ""
  Write-Host "$msg" -ForegroundColor Magenta
  Write-Host "==============================" -ForegroundColor DarkGray
  Write-Host ""
}

function Error {
  param([string]$msg)
  Write-Host "$msg" -ForegroundColor Red
}

function Warning {
  param([string]$msg)
  Write-Host "$msg" -ForegroundColor Yellow
}

function Info {
  param([string]$msg)
  Write-Host "$msg"
}

function Status {
  param([string]$msg)
  Write-Host "$msg" -ForegroundColor Blue
}

function Success {
  param([string]$msg)
  Write-Host "$msg" -ForegroundColor Green
}

function Log-And-Die {
  param([string]$msg)
  Error "Aborting - $msg"
  exit 1
}

# =============================================================================
# Global Variables for File Operations
# =============================================================================

$script:OverwriteAll = $false
$script:SkipAll = $false
$script:BackupAll = $false

# =============================================================================
# File Deployment Functions
# =============================================================================

function Copy-File {
  param(
    [string]$Source,
    [string]$Destination
  )

  $skip = $false
  $overwrite = $false
  $backup = $false

  if ($DryRun) {
    Info "[DRY RUN] Would copy $Source to $Destination"
    return
  }

  if (Test-Path -Path $Destination) {
    if (-not $script:OverwriteAll -and -not $script:BackupAll -and -not $script:SkipAll) {
      Warning "File already exists: $Destination"
      $choice = Read-Host "[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"

      switch -CaseSensitive ($choice) {
        "s" { $skip = $true }
        "o" { $overwrite = $true }
        "b" { $backup = $true }
        "S" { $script:SkipAll = $true }
        "O" { $script:OverwriteAll = $true }
        "B" { $script:BackupAll = $true }
      }
    }
  }

  $overwrite = $overwrite -or $script:OverwriteAll
  $backup = $backup -or $script:BackupAll
  $skip = $skip -or $script:SkipAll

  if ($skip) {
    Info "Skipping $Destination"
    return
  }

  if ($backup -and (Test-Path -Path $Destination)) {
    $backupPath = "${Destination}.backup"
    Move-Item -Path $Destination -Destination $backupPath -Force
    Status "Backed up $Destination to $backupPath"
  }

  if ($overwrite -and (Test-Path -Path $Destination)) {
    Remove-Item -Path $Destination -Recurse -Force
    Status "Overwriting $Destination"
  }

  # Ensure parent directory exists
  $parentDir = Split-Path -Parent $Destination
  if (-not (Test-Path -Path $parentDir)) {
    New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
  }

  if (Test-Path -Path $Source -PathType Container) {
    Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    Status "Copied directory $Source to $Destination"
  } else {
    Copy-Item -Path $Source -Destination $Destination -Force
    Status "Copied $Source to $Destination"
  }
}

# Return a stable identity string (volume + file index) for a path, following
# reparse points, so hardlinks and resolved symlinks compare equal to their
# target. Empty string if the path can't be opened.
$script:FileIdHelperLoaded = $false
function Get-FileId {
  param([string]$Path)

  if (-not $script:FileIdHelperLoaded) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class NativeFileId {
  [StructLayout(LayoutKind.Sequential)]
  struct INFO {
    public uint FileAttributes;
    public System.Runtime.InteropServices.ComTypes.FILETIME CreationTime;
    public System.Runtime.InteropServices.ComTypes.FILETIME LastAccessTime;
    public System.Runtime.InteropServices.ComTypes.FILETIME LastWriteTime;
    public uint VolumeSerialNumber;
    public uint FileSizeHigh;
    public uint FileSizeLow;
    public uint NumberOfLinks;
    public uint FileIndexHigh;
    public uint FileIndexLow;
  }
  [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
  static extern IntPtr CreateFile(string name, uint access, uint share, IntPtr sec, uint disp, uint flags, IntPtr tmpl);
  [DllImport("kernel32.dll", SetLastError=true)]
  static extern bool GetFileInformationByHandle(IntPtr h, out INFO info);
  [DllImport("kernel32.dll", SetLastError=true)]
  static extern bool CloseHandle(IntPtr h);
  public static string Get(string path) {
    IntPtr h = CreateFile(path, 0, 7, IntPtr.Zero, 3, 0x02000000, IntPtr.Zero);
    if (h == new IntPtr(-1)) return "";
    try {
      INFO info;
      if (!GetFileInformationByHandle(h, out info)) return "";
      return info.VolumeSerialNumber + ":" + info.FileIndexHigh + ":" + info.FileIndexLow;
    } finally { CloseHandle(h); }
  }
}
'@
    $script:FileIdHelperLoaded = $true
  }

  return [NativeFileId]::Get($Path)
}

function Test-SameFile {
  param([string]$A, [string]$B)
  $idA = Get-FileId $A
  $idB = Get-FileId $B
  return ($idA -ne "") -and ($idA -eq $idB)
}

# Establish a link at $Destination pointing at $Source. Hardlink first (files
# only, same volume, no privileges); fall back to a symlink (directories or
# cross-volume; needs Developer Mode or admin). Returns $true on success.
function New-Link {
  param([string]$Source, [string]$Destination)

  if (-not (Test-Path -Path $Source -PathType Container)) {
    try {
      New-Item -Path $Destination -ItemType HardLink -Value $Source -Force -ErrorAction Stop | Out-Null
      Status "Hardlinked $Destination -> $Source"
      return $true
    } catch {
      Info "Hardlink not possible ($($_.Exception.Message)); trying symlink"
    }
  }

  try {
    New-Item -Path $Destination -ItemType SymbolicLink -Value $Source -Force -ErrorAction Stop | Out-Null
    Status "Symlinked $Destination -> $Source"
    return $true
  } catch {
    Error "Failed to link ${Destination} -> ${Source}: $($_.Exception.Message)"
    Error "Symlinks need Windows Developer Mode enabled (Settings > System > For developers) or an elevated shell"
    return $false
  }
}

function Link-File {
  param(
    [string]$Source,
    [string]$Destination
  )

  $skip = $false
  $overwrite = $false
  $backup = $false

  if ($DryRun) {
    Info "[DRY RUN] Would link $Source to $Destination"
    return
  }

  if (Test-Path -Path $Destination) {
    if (-not $script:OverwriteAll -and -not $script:BackupAll -and -not $script:SkipAll) {
      # Already linked to the right source (hardlink or symlink)? Nothing to do.
      if (Test-SameFile $Destination $Source) {
        $skip = $true
      }

      if (-not $skip) {
        Warning "File already exists: $Destination"
        $choice = Read-Host "[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"

        switch -CaseSensitive ($choice) {
          "s" { $skip = $true }
          "o" { $overwrite = $true }
          "b" { $backup = $true }
          "S" { $script:SkipAll = $true }
          "O" { $script:OverwriteAll = $true }
          "B" { $script:BackupAll = $true }
        }
      }
    }
  }

  $overwrite = $overwrite -or $script:OverwriteAll
  $backup = $backup -or $script:BackupAll
  $skip = $skip -or $script:SkipAll

  if ($skip) {
    Info "Skipping $Destination"
    return
  }

  if ($backup -and (Test-Path -Path $Destination)) {
    $backupPath = "${Destination}.backup"
    Move-Item -Path $Destination -Destination $backupPath -Force
    Status "Backed up $Destination to $backupPath"
  }

  if ($overwrite -and (Test-Path -Path $Destination)) {
    Remove-Item -Path $Destination -Recurse -Force
    Status "Overwriting $Destination"
  }

  # Ensure parent directory exists
  $parentDir = Split-Path -Parent $Destination
  if (-not (Test-Path -Path $parentDir)) {
    New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
  }

  New-Link -Source $Source -Destination $Destination | Out-Null
}

function Deploy-File {
  param(
    [string]$Source,
    [string]$Destination
  )

  if ($Copy) {
    Copy-File -Source $Source -Destination $Destination
  } else {
    Link-File -Source $Source -Destination $Destination
  }
}

# =============================================================================
# Helper Functions
# =============================================================================

function Reload-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# =============================================================================
# Update Function
# =============================================================================

function Update-Dotfiles {
  Title "Updating dotfiles repository"

  if ($DryRun) {
    Info "[DRY RUN] Would execute: git pull origin main"
    return
  }

  Push-Location $DotfilesDir
  git pull origin main
  Pop-Location

  Success "Updated dotfiles"
}

# =============================================================================
# Application Setup Functions
# =============================================================================

function Setup-VSCode {
  Title "Setting up VSCode"

  $vscodeSettings = Join-Path $DotfilesDir "config/vscode/settings.json"
  $vscodeTarget = Join-Path $env:APPDATA "Code/User/settings.json"

  if (Test-Path $vscodeSettings) {
    Deploy-File -Source $vscodeSettings -Destination $vscodeTarget
  } else {
    Warning "VSCode settings not found at $vscodeSettings"
  }

  $vscodeKeybindings = Join-Path $DotfilesDir "config/vscode/keybindings.json"
  $vscodeKeybindingsTarget = Join-Path $env:APPDATA "Code/User/keybindings.json"

  if (Test-Path $vscodeKeybindings) {
    Deploy-File -Source $vscodeKeybindings -Destination $vscodeKeybindingsTarget
  } else {
    Warning "VSCode keybindings not found at $vscodeKeybindings"
  }

  $vscodeExtensions = Join-Path $DotfilesDir "config/vscode/extensions.txt"
  if (Test-Path $vscodeExtensions) {
    Get-Content -Path $vscodeExtensions | ForEach-Object {
      if ($DryRun) {
        Info "[DRY RUN] Would install extension: $_"
      } else {
        code --install-extension "$_"
      }
    }
  } else {
    Warning "VSCode extensions not found at $vscodeExtensions"
  }
}

function Setup-Zed {
  Title "Setting up Zed"

  $zedConfigDir = Join-Path $DotfilesDir "config/zed"
  $zedTargetDir = Join-Path $env:APPDATA "Zed"

  $zedSettings = Join-Path $zedConfigDir "settings.json"
  $zedKeymap = Join-Path $zedConfigDir "keymap.json"

  if (Test-Path $zedSettings) {
    $targetSettings = Join-Path $zedTargetDir "settings.json"
    Deploy-File -Source $zedSettings -Destination $targetSettings
  } else {
    Warning "Zed settings not found at $zedSettings"
  }

  if (Test-Path $zedKeymap) {
    $targetKeymap = Join-Path $zedTargetDir "keymap.json"
    Deploy-File -Source $zedKeymap -Destination $targetKeymap
  } else {
    Warning "Zed keymap not found at $zedKeymap"
  }
}

function Setup-Neovim {
  Title "Setting up Neovim"

  $nvimSource = Join-Path $DotfilesDir "config/nvim"
  $nvimTarget = Join-Path $env:LOCALAPPDATA "nvim"

  if (Test-Path $nvimSource) {
    Deploy-File -Source $nvimSource -Destination $nvimTarget
  } else {
    Warning "Neovim config not found at $nvimSource"
  }
}

function Setup-Wezterm {
  Title "Setting up Wezterm"

  $weztermSource = Join-Path $DotfilesDir "config/wezterm/wezterm.lua"
  $weztermTarget = Join-Path $env:USERPROFILE ".wezterm.lua"

  if (Test-Path $weztermSource) {
    Deploy-File -Source $weztermSource -Destination $weztermTarget
  } else {
    Warning "Wezterm config not found at $weztermSource"
  }
}

function Setup-Alacritty {
  Title "Setting up Alacritty"

  $alacrittySource = Join-Path $DotfilesDir "config/alacritty/alacritty-win.toml"
  $alacrittyThemesSource = Join-Path $DotfilesDir "config/alacritty/themes"

  $alacrittyTargetDir = Join-Path $env:APPDATA "alacritty"
  $alacrittyTarget = Join-Path $alacrittyTargetDir "alacritty.toml"
  $alacrittyThemesTarget = Join-Path $alacrittyTargetDir "themes"

  if (Test-Path $alacrittySource) {
    Deploy-File -Source $alacrittySource -Destination $alacrittyTarget
  } else {
    Warning "Alacritty config not found at $alacrittySource"
  }

  if (Test-Path $alacrittyThemesSource) {
    Deploy-File -Source $alacrittyThemesSource -Destination $alacrittyThemesTarget
  } else {
    Warning "Alacritty themes not found at $alacrittyThemesSource"
  }
}

function Setup-WindowsTerminal {
  Title "Setting up Windows Terminal"

  $wtSource = Join-Path $DotfilesDir "config/windows-terminal/settings.json"
  $wtTarget = Join-Path $env:LOCALAPPDATA "Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

  if (Test-Path $wtSource) {
    Deploy-File -Source $wtSource -Destination $wtTarget
  } else {
    Warning "Windows Terminal settings not found at $wtSource"
  }
}

function Setup-PowerShell {
  Title "Setting up PowerShell"

  $psSource = Join-Path $DotfilesDir "WindowsPowerShell"
  $psTarget = Join-Path $env:USERPROFILE "Documents/WindowsPowerShell"

  if (Test-Path $psSource) {
    Deploy-File -Source $psSource -Destination $psTarget
  } else {
    Warning "PowerShell config not found at $psSource"
  }
}

function Setup-Starship {
  Title "Setting up Starship"

  $starshipSource = Join-Path $DotfilesDir "config/starship.toml"
  $starshipTargetDir = Join-Path $env:USERPROFILE ".config"
  $starshipTarget = Join-Path $starshipTargetDir "starship.toml"

  if (Test-Path $starshipSource) {
    Deploy-File -Source $starshipSource -Destination $starshipTarget
  } else {
    Warning "Starship config not found at $starshipSource"
  }
}

# =============================================================================
# Winget Installation
# =============================================================================

function Setup-Winget {
  Title "Installing winget programs"

  if ($DryRun) {
    Info "[DRY RUN] Would install applications via winget"
    return
  }

  # Terminal environment
  winget install Alacritty.Alacritty
  winget install starship

  # Terminal tools
  winget install ajeetdsouza.zoxide
  winget install eza-community.eza
  winget install sharkdp.bat
  winget install BurntSushi.ripgrep.MSVC

  # Editors
  winget install Microsoft.VisualStudioCode
  winget install Neovim.Neovim
  winget install zed.zed

  Reload-Path
  Success "Installed winget packages"
}

# =============================================================================
# Main Function
# =============================================================================

function Show-Help {
  Write-Host @"

Usage: .\bootstrap.ps1 [OPTIONS]

OPTIONS:
  -All               Perform all configuration steps
  -Update            Update local dotfile repository
  -Winget            Install applications via winget
  -Copy              Snapshot-copy files instead of linking (no round-trip)
  -UseSymlinks       Deprecated alias; linking is now the default
  -DryRun            Show what would be done without making changes
  -Apps <app1,app2>  Deploy specific apps (vscode, zed, neovim, wezterm, alacritty, terminal, powershell, starship)
  -Help              Show this help message

EXAMPLES:
  .\bootstrap.ps1 -All
  .\bootstrap.ps1 -Update -Apps vscode,zed
  .\bootstrap.ps1 -DryRun -All
  .\bootstrap.ps1 -Copy -Apps neovim

"@
}

function Main {
  if ($Help) {
    Show-Help
    exit 0
  }

  if ($DryRun) {
    Info "Running in dry-run mode"
    Write-Host ""
  }

  $stepsToRun = @()

  if ($All) {
    $stepsToRun = @("update", "vscode", "zed", "neovim", "wezterm", "alacritty", "terminal", "powershell", "starship")
    if ($Winget) {
      $stepsToRun = @("update", "winget") + $stepsToRun
    }
  } else {
    if ($Update) {
      $stepsToRun += "update"
    }
    if ($Winget) {
      $stepsToRun += "winget"
    }
    if ($Apps.Count -gt 0) {
      # Split comma-separated values and trim whitespace
      foreach ($app in $Apps) {
        $appList = $app -split ',' | ForEach-Object { $_.Trim() }
        $stepsToRun += $appList
      }
    }
  }

  if ($stepsToRun.Count -eq 0) {
    Warning "No operations specified. Use -Help for usage information."
    exit 1
  }

  $totalSteps = $stepsToRun.Count
  $currentStep = 0

  foreach ($step in $stepsToRun) {
    $currentStep++
    Info "[$currentStep/$totalSteps] Running: $step"

    switch ($step.ToLower()) {
      "update" { Update-Dotfiles }
      "winget" { Setup-Winget }
      "vscode" { Setup-VSCode }
      "zed" { Setup-Zed }
      "neovim" { Setup-Neovim }
      "wezterm" { Setup-Wezterm }
      "alacritty" { Setup-Alacritty }
      "terminal" { Setup-WindowsTerminal }
      "powershell" { Setup-PowerShell }
      "starship" { Setup-Starship }
      default { Warning "Unknown step: $step" }
    }
  }

  Write-Host ""
  Success "Done!"
}

# =============================================================================
# Execute Main
# =============================================================================

Main
