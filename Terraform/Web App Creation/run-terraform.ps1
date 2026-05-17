param(
    [Parameter(Position = 0, Mandatory = $false)]
    [string]$Command = "plan",

    [Parameter(Position = 1, Mandatory = $false)]
    [string[]]$Arguments = @()
)

$logPath = Join-Path $PSScriptRoot "terraform-output.log"

if (Test-Path $logPath) {
    Remove-Item $logPath -Force
}

$argumentsText = if ($Arguments.Length -gt 0) { $Arguments -join ' ' } else { '' }
$processInfo = New-Object System.Diagnostics.ProcessStartInfo
$processInfo.FileName = "terraform"
$processInfo.Arguments = "$Command $argumentsText"
$processInfo.WorkingDirectory = $PSScriptRoot
$processInfo.RedirectStandardOutput = $true
$processInfo.RedirectStandardError = $true
$processInfo.UseShellExecute = $false
$processInfo.CreateNoWindow = $true

Write-Host "Running: terraform $Command $argumentsText"

$process = [System.Diagnostics.Process]::Start($processInfo)
$stdout = $process.StandardOutput.ReadToEnd()
$stderr = $process.StandardError.ReadToEnd()
$process.WaitForExit()

$stdout | Out-File -FilePath $logPath -Encoding utf8
if ($stderr) {
    Add-Content -Path $logPath -Value "`n--- STDERR ---`n$stderr"
}

Write-Host "Terraform output saved to $logPath"
exit $process.ExitCode
