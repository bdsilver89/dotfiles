param(
  [switch]$update = $true,
  [switch]$winget = $true,
  [switch]$symlinks = $true
)

# NOTE: look at this repo for help initializing windows powershell
# https://github.com/JMOrbegoso/Dotfiles-for-Windows-11/tree/main

$DotfilesDir = Join-Path -Path $HOME -ChildPath "dotfiles";
$ProfileDir = Split-Path -parent $profile;


function Title {
  param([string]$msg)
  Write-Host "$msg" -ForegroundColor "Magenta";
  Write-Host "==============================";
}

function Error {
  param([string]$msg)
  Write-Host "$msg" -ForegroundColor "Red";
}

function Warning {
  param([string]$msg)
  Write-Host "$msg" -ForegroundColor "Yellow";
}

function Info {
  param([string]$msg)
  Write-Host "$msg";
}

function Success {
  param([string]$msg)
  Write-Host "$msg" -ForegroundColor "Green";
}

function ReloadPath {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

function SetupSymlink {
  param([string]$source,[string]$target)

  if (Test-Path -Path $target) {
    Warning "$target path already exists, skipping"
  }
  else {
    New-Item -Path $target -ItemType SymbolicLink -Value $source;
  }
}

if ($update) {
  Title "Updating dotfiles repository";
  git pull origin main;
}

if ($winget) {
  Title "Installing winget programs";

  # terminal environment
  # winget install Cygwin.Cygwin;
  winget install Alacritty.Alacritty

  # terminal tools
  winget install ajeetsouza.zoxide;
  winget install eza-community.eza;
  winget install sharkdp.bat;

  # editors
  winget install Microsoft.VisualStudioCode;
  winget install Neovim.Neovim;

  # development tools
  # winget install Docker.DockerDesktop;

  ReloadPath;
}

if ($symlinks) {
  Title "Setting up symlinks";

  SetupSymlink -source $DotfilesDir/WindowsPowerShell -target $ProfileDir;

  $AlacrittyDir = Join-Path -Path $HOME -ChildPath "AppData/Roaming/alacritty";
  New-Item -Path $AlacrittyDir -ItemType Directory -Force;
  SetupSymlink -source $DotfilesDir/config/alacritty/alacritty-win.toml -target $AlacrittyDir/alacritty.toml;
  SetupSymlink -source $DotfilesDir/config/alacritty/catppuccin-frappe.toml -target $AlacrittyDir/catppucin-frappe.toml;
  SetupSymlink -source $DotfilesDir/config/alacritty/catppuccin-latte.toml -target $AlacrittyDir/catppuccin-latte.toml;
  SetupSymlink -source $DotfilesDir/config/alacritty/catppuccin-macchiato.toml -target $AlacrittyDir/catppucin-macchiato.toml;
  SetupSymlink -source $DotfilesDir/config/alacritty/catppuccin-mocha.toml -target $AlacrittyDir/catppuccin-mocha.toml;
}

Success "Done";
