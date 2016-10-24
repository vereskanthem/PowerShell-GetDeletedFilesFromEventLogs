$DifferenceInDays = -1
$ParallelStreams = 12

$CurrentDate = Get-Date -format "dd.MM.yyyy-HH.mm"
$PreviousDate = "{0:dd.MM.yyyy-HH.mm}" -f (Get-Date).AddDays($DifferenceInDays)
#$PreviousDate = "{0:dd.MM.yyyy-HH.mm}" -f (Get-Date).AddMinutes(-12)

[string]$CurrentDateString = $CurrentDate.ToString()
[string]$PreviousDateString = $PreviousDate.ToString()

$CurrentDateString 
$PreviousDateString

& $PSScriptRoot\RunSearchParallel.ps1 -BeginTime $PreviousDateString -EndTime $CurrentDateString -ParallelStreams $ParallelStreams