# basic commands
function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object Definition }

function Start-VisualStudio([string]$solutionFile) {
  if (($solutionFile -eq $null) -or ($solutionFile -eq "")) {
    $solutionFile = (Get-ChildItem -Filter "*.sln" | Select-Object -First 1).Name
  }
  if (($solutionFile -ne $null) -and ($solutionFile -ne "") -and (Test-Path $solutionFile)) {
    Start-Process devenv -ArgumentList $solutionFile
  } else {
    Start-Process devenv
  }
}

function Get-EnvironmentVariable {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $true)][string] $Name,
    [Parameter(Mandatory = $true)][System.EnvironmentVariableTarget] $Scope,
    [Parameter(Mandatory = $false)][string] $PreserveVariables = $false,
    [Parameter(ValueFromRemainingArguments = $true)][Object[]] $ignoredArguments
  )

  # Do not log function call, it may expose variable names
  ## Called from chocolateysetup.psm1 - wrap any Write-Host in try/catch

  [string] $MACHINE_ENVIRONMENT_REGISTRY_KEY_NAME = "SYSTEM\CurrentControlSet\Control\Session Manager\Environment\";
  [Microsoft.Win32.RegistryKey] $win32RegistryKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($MACHINE_ENVIRONMENT_REGISTRY_KEY_NAME)
  if ($Scope -eq [System.EnvironmentVariableTarget]::User) {
    [string] $USER_ENVIRONMENT_REGISTRY_KEY_NAME = "Environment";
    [Microsoft.Win32.RegistryKey] $win32RegistryKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($USER_ENVIRONMENT_REGISTRY_KEY_NAME)
  }
  elseif ($Scope -eq [System.EnvironmentVariableTarget]::Process) {
    return [Environment]::GetEnvironmentVariable($Name, $Scope)
  }

  [Microsoft.Win32.RegistryValueOptions] $registryValueOptions = [Microsoft.Win32.RegistryValueOptions]::None

  if ($PreserveVariables) {
    Write-Verbose "Choosing not to expand environment names"
    $registryValueOptions = [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
  }

  [string] $environmentVariableValue = [string]::Empty

  try {
    #Write-Verbose "Getting environment variable $Name"
    if ($win32RegistryKey -ne $null) {
      # Some versions of Windows do not have HKCU:\Environment
      $environmentVariableValue = $win32RegistryKey.GetValue($Name, [string]::Empty, $registryValueOptions)
    }
  }
  catch {
    Write-Debug "Unable to retrieve the $Name environment variable. Details: $_"
  }
  finally {
    if ($win32RegistryKey -ne $null) {
      $win32RegistryKey.Close()
    }
  }

  if ($environmentVariableValue -eq $null -or $environmentVariableValue -eq '') {
    $environmentVariableValue = [Environment]::GetEnvironmentVariable($Name, $Scope)
  }

  return $environmentVariableValue
}

function Get-EnvironmentVariableNames([System.EnvironmentVariableTarget] $Scope) {
  switch ($Scope) {
    'User' {
      Get-Item 'HKCU:\Environment' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property
    }
    'Machine' {
      Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property
    }
    'Process' {
      Get-ChildItem Env:\ | Select-Object -ExpandProperty key
    }
    default {
      throw "Unsupported environment scope: $Scope"
    }
  }
}

function Update-SessionEnvironment {
  # Write-FunctionCallLogMessage -Invocation $MyInvocation -Parameters $PSBoundParameters;

  $refreshenv = $false;
  $invocation = $MyInvocation;
  if ($invocation.InvocationName -eq 'refreshenv') {
    $refreshenv = $true;
  }
  if ($refreshenv) {
    Write-Output "Refreshing environment variables from the registry for powershell.exe. Please wait...";
  }
  else {
    Write-Verbose "Refreshing environment variables from the registry.";
  }

  $userName = $env:USERNAME;
  $architecture = $env:PROCESSOR_ARCHITECURE;
  $psModulePath = $env:PSModulePath;

  # ordering is important here, $user should override $machine...
  $ScopeList = 'Process', 'Machine';
  if ('SYSTEM', "${env:COMPUTERNAME}`$" -notcontains $userName) {
    $ScopeList += "User";
  }
  foreach ($Scope in $ScopeList) {
    Get-EnvironmentVariableNames -Scope $Scope |
      ForEach-Object {
        Set-Item "Env:$_" -Value (Get-EnvironmentVariable -Scope $Scope -Name $_)
      }
   }

  # Path gets special treatment b/c munges the two together
  $paths = 'Machine', 'User' |
    ForEach-Object {
      (Get-EnvironmentVariable -Name 'PATH' -Scope $_) -split ';'
    } |
    Select-Object -Unique
  $Env:PATH = $paths -join ';';

  # PSModulePat is almost always updated by process, so we want to preserve it.
  $env:PSModulePath = $psModulePath;

  # reset user and architecture
  if ($userName) {
    $env:USERNAME = $userName;
  }
  if ($architecture) {
    $env:PROCESSOR_ARCHITECTURE = $architecture;
  }

  if ($refreshenv) {
    Write-Output 'Finished';
  }
}
