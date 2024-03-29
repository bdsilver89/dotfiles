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

  $AlacrittyDir = Join-Path -Path $HOME -ChildPath "AppData/Roaming/alacritty";

  SetupSymlink -source $DotfilesDir/WindowsPowerShell -target $ProfileDir;
  SetupSymlink -source $DotfilesDir/config/alacritty -target $AlacrittyDir;
}

Success "Done";
