$vsInstallerDir = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer";
if (Test-Path $vsInstallerDir) {
  $vsWhere = Join-Path -Path $vsInstallerDir -ChildPath "vswhere.exe";

  $vsInstallationPath = & $vsWhere -products * -latest -property installationPath
    & "${vsInstallationPath}\Common7\Tools\Launch-VsDevShell.ps1" -Arch amd64 -SkipAutomaticLocation
}
