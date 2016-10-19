#TEST

#start-job -scriptblock {"C:\Users\vlozhnikov\Desktop\Scripts\PowerShell\GetFilesDeletedInTimeInterval\ParallelTest.ps1 -Par00 1 -Pam11 2 -Pam22 3"}
#& C:\Users\vlozhnikov\Desktop\Scripts\PowerShell\GetFilesDeletedInTimeInterval\ParallelTest.ps1 -Par00 1 -Pam11 2 -Pam22 3
#& C:\Users\vlozhnikov\Desktop\Scripts\PowerShell\GetFilesDeletedInTimeInterval\ParallelTest.ps1 -Par00 4 -Pam11 5 -Pam22 6

#function Output($test) 
#{
#    Write-Host -Foreground "Green" $test
#}
#

Param(
	$MaskToFind,
	$BeginTime,
	$EndTime,
	$SecLog,
	$ArchLogDir,
	[switch]$Test,
	[int32]$ParallelStreams
)

if(!$BeginTime)	{

	$BeginTime = "29.09.2016-12.56"

}

if(!$EndTime)	{

	$EndTime = "29.09.2016-12.58"
	
}

if(!$SecLog)	{

	$SecLog = "F:\Logs\Test.evtx"
	#$SecLog = "C:\Windows\System32\winevt\Logs\Security.evtx"	

}

if(!$ArchLogDir)	{

	$ArchLogDir = "F:\Logs\Archive"
    #$ArchLogDir = "E:\Audit_logs"

}

if(!$ParallelStreams)	{
	
	$ParallelStreams = 2

}

if(!$MaskToFind)	{

	$MaskToFind = ""
	Write-Host -foreground "yellow" "Mask is not set. Setting up empty mask."

}	else	{

	Write-Host -foreground "yellow" "Mask is SET: $MaskToFind"

}
	
if(Test-Path "$PSScriptRoot\Temp\$BeginTime-$EndTime\*")	{

	Remove-Item "$PSScriptRoot\Temp\$BeginTime-$EndTime\*"
	
}	else	{

	Write-Host -foreground "yellow" "Dir $PSScriptRoot\Temp\$BeginTime-$EndTime\ is not exist. Cannot remove data in here. Nothing to do."

}

Write-Host -foreground "Green" "`n ------------------------ SCRIPT BEGUN! ------------------------ `n"

$Script = [scriptblock]::Create("$PSScriptRoot\GetFilesDeletedInTimeInterval.ps1 -SecLog $SecLog -ArchLogDir $ArchLogDir -bt $BeginTime -et $EndTime -LogTimeList -ReturnTimeMassive -DisableOutput -ParallelStreams $ParallelStreams -DisableDebugOutput -OutLogsDateAndTime")
$DividedTimeMassive = @()
[PSObject]$DividedTimeMassive = Invoke-Command -script $script

if(Test-Path "$PSScriptRoot\Result-$BeginTime-$EndTime")	{
	
	Write-Host -foreground "Green" "$PSScriptRoot\Result-$BeginTime-$EndTime"
		
}	else	{
	
	Write-Host -foreground "Yellow" "$PSScriptRoot\Result-$BeginTime-$EndTime"
		
	New-Item "$PSScriptRoot\Result-$BeginTime-$EndTime" -type directory | Out-Null
	
	#Write-Host -foreground "Yellow" "Make $PSScriptRoot\Result-$BeginTime-$EndTime directory."
		
	if(Test-Path "$PSScriptRoot\Result-$BeginTime-$EndTime")	{
		
	Write-Host -foreground "Green" "Directory $PSScriptRoot\Result-$BeginTime-$EndTime is created."
		
	}	else	{
	
		Write-Host -foreground "Red" "Cannot create $PSScriptRoot\Result-$BeginTime-$EndTime directory!"
	
	}

}

if(Test-Path "$PSScriptRoot\Temp\$BeginTime-$EndTime")	{
	
	Write-Host -foreground "Green" "$PSScriptRoot\Temp\$BeginTime-$EndTime"
		
}	else	{
	
	Write-Host -foreground "Yellow" "$PSScriptRoot\Temp\$BeginTime-$EndTime"
		
	New-Item "$PSScriptRoot\Temp\$BeginTime-$EndTime" -type directory | Out-Null
	
	#Write-Host -foreground "Yellow" "Make $PSScriptRoot\Temp\$BeginTime-$EndTime directory."
		
	if(Test-Path "$PSScriptRoot\Temp\$BeginTime-$EndTime")	{
		
	Write-Host -foreground "Green" "Directory $PSScriptRoot\Temp\$BeginTime-$EndTime is created."
		
	}	else	{
	
		Write-Host -foreground "Red" "Cannot create $PSScriptRoot\Temp\$BeginTime-$EndTime directory!"
	
	}

}

Write-Host "--------------------------------------------"

if($SecLog)	{
	
	Write-Host -NoNewLine "SecurityLog: "
	Write-Host -foreground "green" "$SecLog"
	
}	else	{

	Write-Host -foreground "yellow" "SecurityLog is NOT Exist!"

}

if($ArchLogDir)	{
	
	Write-Host -NoNewLine "ArchivedLogDirectory: "
	Write-Host -foreground "green" "$ArchLogDir"
	
}	else	{

	Write-Host -foreground "yellow" "ArchLogDir is NOT Exist!"

}

$Count = 0

$FormattedDateTimeStringMassive = @()

$BeginTimeString = @()
$EndTimeString = @()

foreach($Element in $DividedTimeMassive)	{

	$BufferTimeBegin = $($Element.StreamTimeIntervalBegin)
	$BufferTimeEnd = $($Element.StreamTimeIntervalEnd)
	
	if($BufferTimeBegin)	{
	
		$BufferTimeBeginString = $BufferTimeBegin.ToString()
		
	}
	
	if($BufferTimeEnd)		{
	
		$BufferTimeEndString = $BufferTimeEnd.ToString()
	
	}
	
#	# The only way to have compability ....
#	#-----------------------------------------------------------------
	
	if($BufferTimeBeginString)	{
	
		$BufferTimeBeginString = $BufferTimeBeginString.replace("/",".")
		$BufferTimeBeginString = $BufferTimeBeginString.replace(":",".")
		$BufferTimeBeginString = $BufferTimeBeginString.replace(" ","-")
		$BufferTimeBeginString = $BufferTimeBeginString -replace(".{3}$")
		
		$BufferTimeBegin = [datetime]::ParseExact($BufferTimeBeginString,"MM.dd.yyyy-HH.mm",$null)
		
		$BufferTimeBegin = Get-Date $BufferTimeBegin -format "dd.MM.yyyy-HH.mm"
		
		$BufferTimeBeginString = $BufferTimeBegin.ToString()
	
	}
	
#	#-----------------------------------------------------------------
	
	if($BufferTimeEndString)	{
	
		[string]$BufferTimeEndString = $BufferTimeEnd.ToString()
		
		$BufferTimeEndString = $BufferTimeEndString.replace("/",".")
		$BufferTimeEndString = $BufferTimeEndString.replace(":",".")
		$BufferTimeEndString = $BufferTimeEndString.replace(" ","-")
		$BufferTimeEndString = $BufferTimeEndString -replace(".{3}$")
		
		$BufferTimeEnd = [datetime]::ParseExact($BufferTimeEndString,"MM.dd.yyyy-HH.mm",$null)
		
		$BufferTimeEnd = Get-Date $BufferTimeEnd -format "dd.MM.yyyy-HH.mm"
		
		$BufferTimeEndString = $BufferTimeEnd.ToString()
	
	}
	
	if($BufferTimeBeginString -Or $BufferTimeEndString)	{
	
		$FormattedDateTimeStringElement = New-Object -TypeName PSObject
		$FormattedDateTimeStringElement | Add-Member -Type NoteProperty -Name StreamTimeIntervalBegin -Value "$BufferTimeBeginString"
		$FormattedDateTimeStringElement | Add-Member -Type NoteProperty -Name StreamTimeIntervalEnd -Value "$BufferTimeEndString"
		$FormattedDateTimeStringMassive += $FormattedDateTimeStringElement
		
		$BufferTimeBeginMassive = $BufferTimeBeginString
		$BufferTimeEndMassive   = $BufferTimeEndString
		
		$BeginTimeString += $BufferTimeBeginString
		$EndTimeString += $BufferTimeEndString
		Write-Host "--------------------------------------------"
		Write-Host "BeginTimeString[$Count]: $($BeginTimeString[$Count])"
		Write-Host "EndTimeString[$Count]: $($EndTimeString[$Count])"
		Write-Host "--------------------------------------------"
		
		$Count++
	
	}

}

for($i=0;$i -lt $ParallelStreams;$i++)		{
	
	$StringBuffer = "PP"
	$StringBuffer += "$i"
	$NameJob += $StringBuffer
	
	#Write-Host -foreground "red" "$StringBuffer"
	
}

#$BeginTime = $BeginTime.replace("/",".")
#$BeginTime = $BeginTime.replace(":",".")
#$BeginTime = $BeginTime.replace(" ","-")

#echo $BeginTime

$BeginTimeConv = [datetime]::ParseExact($BeginTime,"dd.MM.yyyy-HH.mm",$null)
$EndTimeConv = [datetime]::ParseExact($EndTime,"dd.MM.yyyy-HH.mm",$null)

$TimeDiff = ($EndTimeConv - $BeginTimeConv)

#Write-Host -foreground "red" $TimeDiff.TotalMinutes

if(!$Test)	{

if($ParallelStreams -le $($TimeDiff.TotalMinutes))	{

$Job = @()
$RunJob = @()

$CountNameJob = $ParallelStreams

for($i=0;$i -lt $ParallelStreams;$i++)		{
	
	$NameJob = "PP"
	$NameJob += $i
	
	if(!$MaskToFind)	{
	
		$Job += [scriptblock]::Create("$PSScriptRoot\GetFilesDeletedInTimeInterval.ps1 -SecLog $SecLog -ArchLogDir $ArchLogDir -bt $($BeginTimeString[$i]) -et $($EndTimeString[$i]) -GlobalIntervalBegin $BeginTime -GlobalIntervalEnd $EndTime -DisableDebugOutput")
		
	}	else	{
	
		$Job += [scriptblock]::Create("$PSScriptRoot\GetFilesDeletedInTimeInterval.ps1 -SecLog $SecLog -ArchLogDir $ArchLogDir -bt $($BeginTimeString[$i]) -et $($EndTimeString[$i]) -GlobalIntervalBegin $BeginTime -GlobalIntervalEnd $EndTime -DisableDebugOutput -Mask $MaskToFind")
	
	}
	
	$RunJob += Start-Job -Name $NameJob -scriptblock $($Job[$i])
	Start-Sleep -m 500

}

while(Get-Job -State Running)	{

	for($JCount=0;$JCount -lt $ParallelStreams;$JCount++)	{
	
		Receive-Job -Job $($RunJob[$JCount])
		Start-Sleep -m 500
	
	}
}

}	else 	{

	Write-Host -foreground "red" "Cannot run! Time interval (in MINUTES) MUST be highter then ParallelStreams count!"

}

}

$a = "<style>"
#$a = $a + "body{font-family:Georgia, Times, serif;color:purple;background-color:#d8da3d}h1{font-family:Helvetica, Arial}"
$a = $a + "body {
    font-family:  Geneva, Verdana, sans-serif;
	font-size: 12px;
    color: black;
    background-color: #CDCDB4
}
h1 {
    font-family: Helvetica, Arial
}"

$a = $a + "BODY{background-color:#E0EEE0;}"
$a = $a + "TABLE{border-width: 2px;border-style: solid;border-color: black;border-collapse: collapse; font-size: 12px;}"
$a = $a + "TH{border-width: 2px;padding: 2px;border-style: solid;border-color: black;background-color:#E0EEE0}"
$a = $a + "TD{border-width: 2px;padding: 2px;border-style: solid;border-color: black;background-color:#E0EEEE}"
$a = $a + "</style>"
$a = $a + "<H2> Security Event Log: List of files deleted from $env:computername sorted by time. Time Interval: $BeginTime - $EndTime </H2>"

$FinalHtml = "$PSScriptRoot\Result-$BeginTime-$EndTime\FilesDeletedFrom-$BeginTime-$EndTime.html"

$HtmlEnd = "<br><br>"

$ContentOfAllFiles = $a

Get-ChildItem "$PSScriptRoot\Temp\$BeginTime-$EndTime" | foreach	{
	
	$FullpathToOneFile = $_.fullname
	#echo $_.fullname
	$ContentOfFile = Get-Content "$FullpathToOneFile"
	$ContentOfFile += $HtmlEnd
	
	$ContentOfAllFiles += $ContentOfFile

}

#ECHO $ContentOfAllFiles

try	{
	
	$ContentOfAllFiles | Out-File $FinalHtml #| Set-Content $FinalHtml
	
}	catch	{

	Write-Host -foreground "yellow" "Cannot merge html files! Check Permissions."

}

Write-Host -foreground "Green" "`n ------------------------ SCRIPT END! ------------------------ `n"



