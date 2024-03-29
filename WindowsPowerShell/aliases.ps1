
# mimic chocolatey's refresh env
Set-Alias refreshenv Update-SessionEnvironment

# Set-Alias cl clear;

# Set-Alias c bat;

if (Get-Command zoxide -ErrorAction SilentlyContinue | Test-Path) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if (Get-Command starship -ErrorAction SilentlyContinue | Test-Path) {
  Invoke-Expression (&starship init powershell)
}

if (Get-Command eza -ErrorAction SilentlyContinue | Test-Path) {
  ${function:ls} = { eza --icons --git}
  ${function:l} = { eza -l --icons --git}
  ${function:lt} = { eza --tree --level=2 --long --icons --git}
}


#
# configure visual studio
