param (
    [int]$value
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName PresentationFramework

if ($value -ge 1 -and $value -le 100) {
    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX $value
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX $value
    powercfg /SETACTIVE SCHEME_CURRENT
    [System.Windows.MessageBox]::Show("Set AC and DC Processor MAX to $value.", "Complete")
} else {
    $output = powercfg /QUERY SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX
    $lines = $output -split "`n"
    $acValue = -1
    $dcValue = -1

    foreach ($line in $lines) {
        if ($line -match " AC .*?: 0x([0-9A-Fa-f]+)$") {
            $acValue = [convert]::ToInt32($matches[1], 16)
        }
        if ($line -match " DC .*?: 0x([0-9A-Fa-f]+)$") {
            $dcValue = [convert]::ToInt32($matches[1], 16)
        }
    }
    [System.Windows.MessageBox]::Show("Current CPU MAX (AC): $acValue`nCurrent CPU MAX (DC): $dcValue", "Current State")
}
