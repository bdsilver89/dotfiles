#!/usr/bin/env pwsh

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }
try {
    $payload = $raw | ConvertFrom-Json
} catch {
    exit 0
}
if ($null -eq $payload) { exit 0 }

function Get-Prop {
    param($obj, [string]$path, $default = $null)
    foreach ($key in $path.Split('.')) {
        if ($null -eq $obj) { return $default }
        $prop = $obj.PSObject.Properties[$key]
        if ($null -eq $prop) { return $default }
        $obj = $prop.Value
    }
    if ($null -eq $obj) { return $default }
    return $obj
}

$model = Get-Prop $payload 'model.display_name' ''
$dir = Get-Prop $payload 'workspace.current_dir' ''
$pctRaw = Get-Prop $payload 'context_window.used_percentage' 0
$usedIn = [long](Get-Prop $payload 'context_window.total_input_tokens' 0)
$usedOut = [long](Get-Prop $payload 'context_window.total_output_tokens' 0)
$max = [long](Get-Prop $payload 'context_window.context_window_size' 200000)
$effort = Get-Prop $payload 'effort.level' ''
$cost = [double](Get-Prop $payload 'cost.total_cost_usd' 0)
$durationMs = [long](Get-Prop $payload 'cost.total_duration_ms' 0)

$pct = [int][math]::Floor([double]$pctRaw)

$ESC = [char]27
$CYAN = "${ESC}[36m"
$GREEN = "${ESC}[32m"
$YELLOW = "${ESC}[33m"
$RED = "${ESC}[31m"
$MAGENTA = "${ESC}[35m"
$BLUE = "${ESC}[34m"
$DIM = "${ESC}[2m"
$RESET = "${ESC}[0m"

$folder = if ($dir) { ($dir -split '[\\/]')[-1] } else { '' }

$branch = ''
if ($dir -and (Test-Path $dir) -and (Get-Command git -ErrorAction SilentlyContinue)) {
    git -C "$dir" rev-parse --git-dir 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $branch = git -C "$dir" branch --show-current 2>$null
    }
}

if ($pct -ge 90) {
    $pctColor = $RED
} elseif ($pct -ge 70) {
    $pctColor = $YELLOW
} else {
    $pctColor = $GREEN
}

switch($effort) {
    'max' { $effortColor = $RED }
    'high' { $effortColor = $YELLOW }
    'medium' { $effortColor = $GREEN }
    default { $effortColor = $DIM }
}

$used = $usedIn + $usedOut

function Format-Tokens {
    param([long]$n)
    if ($n -ge 1000000) {
        return ('{0:0.0}M' -f ($n / 1MB))
    } elseif ($n -ge 1000) {
        return ('{0:0.0}K' -f ($n / 1KB))
    } else {
        return "$n"
    }
}

$usedFmt = Format-Tokens $used
$maxFmt = Format-Tokens $max

$costFmt = '${0:0.00}' -f $cost

$durationSec = [long][math]::Floor($durationMs / 1000)
$mins = [long][math]::Floor($durationSec / 60)
$secs = $durationSec % 60
$durationFmt = '{0}m {1:00}s' -f $mins, $secs

$SEP = "${DIM} | ${RESET}"

$out = "$CYAN$model$RESET"
if ($effort) { $out += "$SEP$effortColor$effort$RESET" }
$out += "$SEP$BLUE$folder$RESET"
if ($branch) { $out += "$SEP$MAGENTA$branch$RESET" }
$out += "$SEP$pctColor$usedFmt/$maxFmt ($pct`%)$RESET"
$out += "$SEP$YELLOW$costFmt$RESET"
$out += "$SEP$CYAN$durationFmt$RESET"