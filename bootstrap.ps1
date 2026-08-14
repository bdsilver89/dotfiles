#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Source,
    [string]$Repo = $env:DOTFILES_REPO,
    [ValidateSet('desktop', 'headless')][string]$Role,
    [string]$Theme,
    [string]$Email,
    [string]$Exclude,
    [switch]$Work,
    [switch]$NoWork,
    [switch]$Yes
)
$ErrorActionPreference = 'Stop'
if (-not $Repo) { $Repo = 'git@github.com:brian/dotfiles.git' }
function Log($m) { Write-Host "==> $m" -ForegroundColor Cyan }

# chezmoi keys --promptString/--promptBool by the PROMPT TEXT, not by the data
# key, so these must match home/.chezmoi.toml.tmpl verbatim.
$P_ROLE  = 'Machine role (desktop/headless)'
$P_THEME = 'Colour scheme'
$P_EMAIL = 'Git email'
$P_WORK  = 'Is this a work machine?'

# The PowerShell profile will not load under the default machine policy.
if ((Get-ExecutionPolicy -Scope CurrentUser) -in @('Undefined', 'Restricted')) {
    Log 'setting execution policy to RemoteSigned for the current user'
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
}

# The package script sets these persistently, but it runs *inside* the apply.
# Set them here too so the templates rendered by this very invocation already
# see them.
foreach ($p in @(
        @{ n = 'XDG_CONFIG_HOME'; v = "$env:USERPROFILE\.config" },
        @{ n = 'XDG_DATA_HOME'; v = "$env:USERPROFILE\.local\share" },
        @{ n = 'XDG_CACHE_HOME'; v = "$env:USERPROFILE\.cache" })) {
    [Environment]::SetEnvironmentVariable($p.n, $p.v, 'User')
    Set-Item -Path "Env:$($p.n)" -Value $p.v
}

foreach ($id in 'Git.Git', 'Microsoft.PowerShell', 'twpayne.chezmoi') {
    if (-not (winget list --id $id -e 2>$null | Select-String -SimpleMatch $id)) {
        Log "winget install $id"
        winget install --id $id -e --silent `
            --accept-package-agreements --accept-source-agreements
    }
}
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User')

$a = @('init', '--apply')
if ($Source) { $a += @('--source', $Source) } else { $a += $Repo }
if ($Role) { $a += @('--promptString', "$P_ROLE=$Role") }
if ($Theme) { $a += @('--promptString', "$P_THEME=$Theme") }
if ($Email) { $a += @('--promptString', "$P_EMAIL=$Email") }
if ($Work) { $a += @('--promptBool', "$P_WORK=true") }
if ($NoWork) { $a += @('--promptBool', "$P_WORK=false") }
if ($Exclude) { $a += @('--exclude', $Exclude) }
if ($Yes) { $a += @('--promptDefaults', '--no-tty', '--force') }

Log "chezmoi $($a -join ' ')"
& chezmoi @a
exit $LASTEXITCODE
