# SecurityEventLog - file named Security.evtx (Usually is it C:\Windows\System32\winevt\Logs)
# ArchiveSecurityEventLogDir - dir with archieved event log files (In our case - G:\Logs)
# FullPathToDirectory - full path to dir where same files were deleted by users
# DeltaTime - Set time interval in days before this date.

#$SecurityEventLog = "C:\Windows\System32\winevt\Logs\Security.evtx"

#workflow Run-Parallel	{

Param(
	[switch]$LogTimeList,
	[switch]$ReturnTimeMassive,
	[string]$Mask,
	[string]$bt,
	[string]$et,
	[string]$GlobalIntervalBegin,
	[string]$GlobalIntervalEnd,
	[string]$SecLog,
	[string]$ArchLogDir,
	[switch]$Debug1,
	[switch]$Debug2,
	[switch]$Debug3,
	[switch]$Debug4,
	[switch]$RunRecurse,
	[int32]$ParallelStreams,
	[switch]$DisableDebugOutput,
	[switch]$OutLogsDateAndTime
)

$CommonTimeIntervalBegin
$CommonTimeIntervalEnd
$TimeDifference

#$OutputEncoding = New-Object -typename System.Text.UTF8Encoding
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("866")
#[Console]::OutputEncoding = [System.Text.Encoding]::

#function ParallelReplica($LogTimeList,$Mask,$bt,$et,$SecLog,$ArchLogDir,$Debug1,$Debug2,$EnableReturnFirstEventsObject,$EnableReturnLastEventsObject,$DisableDebugOutput)	{

if(!$DisableDebugOutput)	{

Write-Host -foreground "Green" "`n ------------------------ SCRIPT BEGUN! ------------------------ `n"

Write-Host "Êèðèëëèöà."

Write-Host  "Entered Parametres:"
if($Mask)	{Write-Host -NoNewLine "Mask: 			   `t"; Write-Host -foreground "red" "$Mask"}
if($bt)		{Write-Host -NoNewLine "TimeIntervalBegin: `t"; Write-Host -foreground "green" "$bt"}
if($et)		{Write-Host -NoNewLine "TimeIntervalEnd:   `t"; Write-Host -foreground "green" "$et"}

if($LogTimeList)	{

	Write-Host -foreground "green" "Only Log List with parsed Time will be printed!"

}	else	{

	if(!$bt)	{Write-Host -foreground "Red" "Set Begin Time with -bt parameter!";exit}
	if(!$et)	{Write-Host -foreground "Red" "Set End Time with -et parameter!";exit}

}

}

if($SecLog -eq '')	{

	if(!$DisableDebugOutput)	{	
	
		Write-Host -foreground "Yellow" "SecLog parameter is not set! Select default value."
		
	}
	
	$SecurityEventLog = "C:\Windows\System32\winevt\Logs\Security.evtx"	
	
	if(!$DisableDebugOutput)	{
	
		Write-Host -foreground "green" "SecLog: $SecurityEventLog"
	}
	
}	else	{
	
	$SecurityEventLog = $SecLog
	
	if(!$DisableDebugOutput)	{	
		
		Write-Host -foreground "green" "SecLog: $SecLog"
		
	}
	
}

if($ArchLogDir -eq '')	{

	if(!$DisableDebugOutput)	{	
		
		Write-Host -foreground "Red" "ArchLogDir parameter is not set! You MUST set archive security logs path!"
	
	}	
	exit

}

#$SecurityEventLog = "F:\Logs\Test2.evtx"
$ArchiveSecurityEventLogDir = $ArchLogDir
#$ArchiveSecurityEventLogDir = "F:\Logs\Archive"

$StartRuntime = (Get-Date).Second

if(!$DisableDebugOutput)	{

	echo "----------------------------------------"
	
}

if(Test-Path $ArchiveSecurityEventLogDir)	{

	if(!$DisableDebugOutput)	{	
	
		echo "Path $ArchiveSecurityEventLogDir is exist."
	
	}

}	else	{

	if(!$DisableDebugOutput)	{	
	
		echo "Path $ArchiveSecurityEventLogDir is NOT exist! Check your spelling or parameter named SecurityEventLog!"
		
	}
	return

}

if(Test-Path $SecurityEventLog)	{

	if(!$DisableDebugOutput)	{	
		
		echo "File $SecurityEventLog is exist."
		
	}

}   else	{

	if(!$DisableDebugOutput)	{	
	
		echo "Path $SecurityEventLog is NOT exist! Check your spelling or parameter named ArchiveSecurityEventLogDir!"
	
	}
	return

}

if(Test-Path "$PSScriptRoot\Temp")	{

	if(!$DisableDebugOutput)	{	
	
		Write-Host -foreground "Green" "Temp is Exist!"
		
	}

}	else	{
	
	if(!$DisableDebugOutput)	{	
	
		Write-Host -foreground "Yellow" "$PSScriptRoot\Temp is NOT Exist!"
		
	}
	New-Item "$PSScriptRoot\Temp" -type directory | Out-Null
	
	if(!$DisableDebugOutput)	{	
		
		Write-Host -foreground "Yellow" "Make $PSScriptRoot\Temp directory."
		
	}
		
	if(Test-Path "$PSScriptRoot\Temp")	{
		
		if(!$DisableDebugOutput)	{	
		
			Write-Host -foreground "Green" "$PSScriptRoot\Temp dir was maked."
		
		}

	}	else	{
	
		if(!$DisableDebugOutput)	{	
		
			Write-Host -foreground "Red" "Cannot make $PSScriptRoot\Temp dir!"
			
		}
	
	}
	
}

if(!$DisableDebugOutput)	{
	
	echo "----------------------------------------"
	
}

$ListOfSecurityEventLogs = @()

$CountChildItem = 0

Get-ChildItem $ArchiveSecurityEventLogDir\*	 -include *.evtx | Select -Property Name | foreach {

	$CountChildItem++
	$Item = $_.Name
	$ListOfSecurityEventLogs += $ArchiveSecurityEventLogDir+"\"+$Item

}

$ListOfSecurityEventLogs += $SecurityEventLog

if(!$DisableDebugOutput)	{	

	echo "List Of Files With Security Event Logs: "
	echo "----------------------------------------"
	echo $ListOfSecurityEventLogs
	echo "----------------------------------------"
	
}

$FirstEventInLog = @()
$LastEventInLog =  @()
$TimeFirstEvent =  @()
$TimeLastEvent =   @()

for($i=0;$i -le $CountChildItem;$i++)	{

	[string]$CurrentLogFile = $ListOfSecurityEventLogs[$i]
	
	if($OutLogsDateAndTime)	{		
	
		Write-Host "Try to get 1'st and Last Element In Event Log named $CurrentLogFile..."
		Write-Host "----------------------------------------------------------------------"
	
	}
	
	$FirstEventInLog += Get-WinEvent @{Path=$CurrentLogFile} -MaxEvents 1 -Oldest
	$TimeFirstEvent  += $FirstEventInLog[$i].TimeCreated

	$LastEventInLog += Get-WinEvent @{Path=$CurrentLogFile} -MaxEvents 1
	$TimeLastEvent  += $LastEventInLog[$i].TimeCreated
	
	$TimeB = $TimeFirstEvent[$i]
	$TimeE = $TimeLastEvent[$i]
	
	if($OutLogsDateAndTime)	{	
	
		Write-Host -background "black" -foreground "green" "LogTimeBegin: $TimeB"
		Write-Host -background "black" -foreground "green" "LogTimeEnd:   $TimeE"
		Write-Host "----------------------------------------------------------------------"	
	}
	
}

#if($LogTimeList)	{
	
	#if($EnableReturnFirstEventsObject)	{
	
	#	return $FirstEventInLog
		
	#}
		
	#if($EnableReturnLastEventsObject)	{
	
	#	return $LastEventInLog
		
	#}

#}
if(!$DisableDebugOutput)	{	
	
	echo "----------------------------------------"
	
}

if(!$Mask -Or $Mask -eq "")	{
	
	$FullPathToDirectoryOrFile = ""

}

if($Mask)	{

	$FullPathToDirectoryOrFile = $Mask
	#Write-Host -foreground "red" "$FullPathToDirectoryOrFile"
	
}

if(!$LogTimeList)	{

	if(!$FullPathToDirectoryOrFile)	{

#		$FullPathToDirectoryOrFile = ""
		if(!$FullPathToDirectoryOrFile) {
		
			if(!$DisableDebugOutput)	{	
			
				echo "Selecting all files (Value of entry string is not set)!"
				
			}
		
		}
		else {
		
			if(!$DisableDebugOutput)	{	
			
				echo "Selecting files and paths with $FullPathToDirectoryOrFile String!"
				
			}
		}
	
	}

}

if($bt)	{[string]$FirstDateTimeString = $bt}
if($et)	{[string]$SecondDateTimeString = $et}

#echo "FirstDateTimeString = $FirstDateTimeString"
#echo "SecondDateTimeString = $SecondDateTimeString"

#if($LogTimeList)	{exit}

$FirstDateTimeLimit = [datetime]::ParseExact($FirstDateTimeString,"dd.MM.yyyy-HH.mm",$null)
#echo $FirstDateTimeLimit

$SecondDateTimeLimit = [datetime]::ParseExact($SecondDateTimeString,"dd.MM.yyyy-HH.mm",$null)
#echo $SecondDateTimeLimit	

if(!$FirstDateTimeLimit)	{

	if(!$DisableDebugOutput)	{	
	
		echo "Set First Time Limit with -bt parameter!"
		
	}
	
	exit
	
}	else 	{
	
	#echo "BeginTime: $FirstDateTimeLimit"

}

if(!$SecondDateTimeLimit)	{

	if(!$DisableDebugOutput)	{	
	
		echo "Set Second Time Limit with -et parameter!"
	
	}
	
	exit
	
}	else 	{
	
	#echo "EndTime: $SecondDateTimeLimit"

}

if($($TimeLastEvent[$CountChildItem]) -gt $FirstDateTimeLimit)	{

	if(!$DisableDebugOutput)	{	
	
		Write-Host $bt 
		
	}
	
}	else	{

	if(!$DisableDebugOutput)	{	
	
		Write-Host -foreground "red" "Begin Time Greater then End Time of logs. Set Correct Time Limit!"
		
	}
	exit 
	
}

if($($TimeFirstEvent[0]) -lt $SecondDateTimeLimit)	{
	
	if(!$DisableDebugOutput)	{	
	
		Write-Host $et
		
	}
	
}	else	{
	
	if(!$DisableDebugOutput)	{	
	
		Write-Host -foreground "red" "End Time Lower then Begin Time of logs. Set Correct Time Limit!"
		Write-Host -foreground "yellow" "$($TimeFirstEvent[0]) > $SecondDateTimeLimit"
		
	}
	exit 	

}

if(!$DisableDebugOutput)	{	

	echo "----------------------------------------"
	
}

$TimeCount = 0
$CountLog = 0

$BeginTime = @()
$EndTime = @()

#[string]$LogFileNameSelector
$LogFileNameMassive = @()
#$LogFileNameMassiveCount = 0

if($FirstDateTimeLimit -le $($TimeFirstEvent[0]))	{

	$GlobalBeginTime = $($TimeFirstEvent[0])
	
	if(!$DisableDebugOutput)	{	
	
		Write-Host -foreground "green" "GlobalBeginTime: $GlobalBeginTime"
		
	}

}	else	{
	
	if(!$DisableDebugOutput)	{	
		
		Write-Host "Time intervals beetwen Global Log Time"
		
	}

}

if($SecondDateTimeLimit -ge $($TimeLastEvent[$TimeCount]))	{
		
	$GlobalEndTime = $($TimeLastEvent[$TimeCount-1])
	
	if(!$DisableDebugOutput)	{	
		
		Write-Host -foreground "green" "GlobalEndTime:   $GlobalEndTime"
		
	}

}	else	{
	
	if(!$DisableDebugOutput)	{	
		
		Write-Host "Time intervals beetwen Global Log Time"
		
	}

}

foreach ($Element in $ListOfSecurityEventLogs)	{
	
	$Trigger = 1;
	
#	echo "----------------------------"
#	echo "$TimeCount : $FirstDateTimeLimit - First Time Limit "
#	echo "$TimeCount : $SecondDateTimeLimit - Second Time Limit "
#	echo "$TimeCount : $($TimeFirstEvent[$TimeCount]) - File $Element Begin Time"
#	echo "$TimeCount : $($TimeLastEvent[$TimeCount]) - File $Element End Time"
#	echo "----------------------------"
	
	if($FirstDateTimeLimit -le $GlobalBeginTime)	{
	
		$FirstDateTimeLimit = $GlobalBeginTime
	
	}

	if($SecondDateTimeLimit -ge $GlobalEndTime)		{
	
		$SecondDateTimeLimit = $GlobalEndTime
	
	}
	
	if(($FirstDateTimeLimit -ge $($TimeFirstEvent[$TimeCount])) -And ($FirstDateTimeLimit -le $($TimeLastEvent[$TimeCount])))	{
	  
		if($Trigger)	{
			
			if(!$DisableDebugOutput)	{	
				
				Write-Host -NoNewLine -foreground "green" " :: IF1 :: "
				
			}
		
			$CountLog++
			$Trigger=0
	
			$LogFileNameMassive += $Element
		
			$BeginTime += $FirstDateTimeLimit
			#$EndTime   += $TimeLastEvent[$TimeCount]
			
			if(($SecondDateTimeLimit -ge $($TimeFirstEvent[$TimeCount])) -And ($FirstDateTimeLimit -le $($TimeLastEvent[$TimeCount])))	{
				
				$EndTime += $SecondDateTimeLimit
				
			}	else	{
			
				$EndTime += $TimeLastEvent[$TimeCount]
			
			}
			
			if(!$DisableDebugOutput)	{	
				
				Write-Host " [ $($BeginTime[$CountLog]) - $($EndTime[$CountLog]) ] in file: $Element"
				
			}
			
		}
		
	}
	
	if(($FirstDateTimeLimit -le $($TimeFirstEvent[$TimeCount])) -And ($SecondDateTimeLimit -ge $($TimeLastEvent[$TimeCount])))	{
		
		if(($FirstDateTimeLimit -ge $GlobalBeginTime) -And ($SecondDateTimeLimit -le $GlobalEndTime))	{
	
			if($Trigger)	{
				
				if(!$DisableDebugOutput)	{	
					
					Write-Host -NoNewLine -foreground "green" " :: IF2 :: "
					
				}
		
				$CountLog++
				$Trigger=0
			
				$LogFileNameMassive += $Element
				
				$BeginTime += $TimeFirstEvent[$TimeCount]
				$EndTime   += $TimeLastEvent[$TimeCount]
				
				if(!$DisableDebugOutput)	{	
					
					Write-Host " [ $($BeginTime[$CountLog]) - $($EndTime[$CountLog]) ] in file: $Element"
					
				}
		
			}
		
		}
	
	}
	
	if(($SecondDateTimeLimit -ge $($TimeFirstEvent[$TimeCount])) -And ($SecondDateTimeLimit -le $($TimeLastEvent[$TimeCount])))	{
		
		if($Trigger)	{
		
			if(!$DisableDebugOutput)	{	
				
				Write-Host -NoNewLine -foreground "green" " :: IF3 :: "
				
			}
		
			$CountLog++
			$Trigger=0
		
			$LogFileNameMassive += $Element
			
			$BeginTime += $TimeFirstEvent[$TimeCount]
			$EndTime   += $SecondDateTimeLimit
			
			if(!$DisableDebugOutput)	{	
				
				Write-Host " [ $($BeginTime[$CountLog]) - $($EndTime[$CountLog]) ] in file: $Element"
				
			}
			
		}
		
	}
	
#	if(($SecondDateTimeLimit -ge $($TimeLastEvent[$TimeCount])))		{
#	
#		echo " :: 2 :: "
#				
#		if($Trigger)	{$CountLog++;$Trigger=0}
#		
#		$LogFileNameMassive += $Element
#		
#		$BeginTime += $TimeFirstEvent[$TimeCount]
#		$EndTime   += $FirstDateTimeLimit
#		
#		echo "$TimeCount 'st Interval: [ $($BeginTime[$TimeCount]) - $($EndTime[$TimeCount]) ] in file: $Element"
#	
#	}
	
	$TimeCount++
	
}

#$LogFileNameSelector = $LogFileNameMassive[0]

#[int32]$CountElement = 0

#foreach($Element in $LogFileNameMassive) {
#
#	$CountElement++
#
#}
#
#Write-Host -foreground "red" "Count of Files with necessary time interval: $CountElement " 

#if($Debug1)	{
#	
#	Write-Host -background "white" -foreground "blue" "Debug1 is set! Exit"
#	exit
#
#}

if(!$DisableDebugOutput)	{	

	for($i = 0; $i -lt $CountLog; $i++)	{
	
		echo "$($LogFileNameMassive[$i])"
		echo "----------------------------"
		echo "BeginTime : $($BeginTime[$i])"
		echo "EndTime   : $($EndTime[$i])"
		echo "----------------------------"
		
	}

}

if($LogTimeList)	{
	
	if(!$DisableDebugOutput)	{	
	
		Write-Host -foreground "Green" "`n ------------------------ First Part of this SCRIPT is END! Log parsing process is running... ------------------------ `n"
	
	}
	if(!$ParallelStreams)	{
	
		$ParallelStreams = 2
	
	}
	
	$CommonTimeIntervalBegin = $($BeginTime[0])
	$CommonTimeIntervalEnd = $($EndTime[$CountLog - 1])
	$TimeDifference = ($CommonTimeIntervalEnd - $CommonTimeIntervalBegin)
	
	#= new-TimeSpan($TimeDifference.Ticks / $ParallelStreams)
	if(!$DisableDebugOutput)	{	
	
		Write-Host "------------------------------------------------"
		Write-Host "CommonTimeIntervalBegin: $CommonTimeIntervalBegin"
		Write-Host "CommonTimeIntervalEnd: $CommonTimeIntervalEnd"
		Write-Host "TimeDifference: $TimeDifference"
		Write-Host "------------------------------------------------"
	
	}
	#[int32]$DayDifference = $TimeDifference.Days
	#[int32]$HourDifference = $TimeDifference.Hours
	#[int32]$MinuteDifference = $TimeDifference.Minutes
	[int32]$MinuteDifferenceTotal = $TimeDifference.TotalMinutes
	
	#$SummaryMinutesDifference = ($DayDifference * 24 * 60) + ($HourDifference * 60) + $MinuteDifference
	$TimeDifferenceDividedByCountOfStreams = $MinuteDifferenceTotal / $ParallelStreams
	
	$DividedTimeMassive = @()
	
	$TimeBuffer = $CommonTimeIntervalBegin
	
	if(!$DisableDebugOutput)	{
	
		echo "TimeBuffer = $TimeBuffer"
		
	}
	
	for($i = 0; $i -lt $ParallelStreams; $i++)	{
		
		$DateTimeElement = New-Object -TypeName PSObject
		$DateTimeElement | Add-Member -Type NoteProperty -Name StreamTimeIntervalBegin -Value "$TimeBuffer"
		
		$TimeBuffer = $TimeBuffer.AddMinutes($TimeDifferenceDividedByCountOfStreams)
		
		$DateTimeElement | Add-Member -Type NoteProperty -Name StreamTimeIntervalEnd -Value "$TimeBuffer"
		$DividedTimeMassive += $DateTimeElement
		
		if(!$DisableDebugOutput)	{	
			
			Write-Host "StreamTimeIntervalBegin: $($DateTimeElement.StreamTimeIntervalBegin)"
			Write-Host "StreamTimeIntervalEnd: $($DateTimeElement.StreamTimeIntervalEnd)"
		
		}
		
	}
	
	if($ReturnTimeMassive)	{
	
		return $DividedTimeMassive
		#exit
	
	}
	
	if(!$DisableDebugOutput)	{	
	
		Write-Host "------------------------------------------------"
		#Write-Host "DayDifference: $DayDifference"
		#Write-Host "HourDifference: $HourDifference"
		#Write-Host "MinuteDifference: $MinuteDifference"
		Write-Host "MinuteDifferenceTotal: $MinuteDifferenceTotal"
		#Write-Host "SummaryMinutesDifference: $SummaryMinutesDifference"
		Write-Host "TimeDifferenceDividedByCountOfStreams : $TimeDifferenceDividedByCountOfStreams "
		Write-Host "------------------------------------------------"
	
	}
	
	if($Debug3Parm)	{
		
		Write-Host -background "white" -foreground "black" "Debug3Parm is set! Exit."
		exit
		
	}
	
#	if($RunRecurse)	{
#	
#		# One Stream 
#		# ParallelReplica 0 $MaskParm $btParm $etParm $SecLogParm $ArchLogDirParm 0 0 0 0
#		
#		# Multiple Streams
#		
#		$FormattedDateTimeStringMassive = @()
#		
#		$BufferTimeBeginMassive = @()
#		$BufferTimeEndMassive   = @()
#		
#		$Count = 0
#		
#		foreach($Element in $DividedTimeMassive)	{
#			
#			$BufferTimeBegin = $($Element.StreamTimeIntervalBegin)
#			$BufferTimeEnd = $($Element.StreamTimeIntervalEnd)
#			
#			# Form a String for enter time parametres with correct type
#
#			[string]$BufferTimeBeginString = $BufferTimeBegin.ToString()
#			
#			# The only way to have compability ....
#			#-----------------------------------------------------------------
#			
#			$BufferTimeBeginString = $BufferTimeBeginString.replace("/",".")
#			$BufferTimeBeginString = $BufferTimeBeginString.replace(":",".")
#			$BufferTimeBeginString = $BufferTimeBeginString.replace(" ","-")
#			$BufferTimeBeginString = $BufferTimeBeginString -replace(".{3}$")
#			
#			$BufferTimeBegin = [datetime]::ParseExact($BufferTimeBeginString,"MM.dd.yyyy-HH.mm",$null)
#			
#			$BufferTimeBegin = Get-Date $BufferTimeBegin -format "dd.MM.yyyy-HH.mm"
#			
#			$BufferTimeBeginString = $BufferTimeBegin.ToString()
#			
#			#-----------------------------------------------------------------
#			
#			[string]$BufferTimeEndString = $BufferTimeEnd.ToString()
#			
#			$BufferTimeEndString = $BufferTimeEndString.replace("/",".")
#			$BufferTimeEndString = $BufferTimeEndString.replace(":",".")
#			$BufferTimeEndString = $BufferTimeEndString.replace(" ","-")
#			$BufferTimeEndString = $BufferTimeEndString -replace(".{3}$")
#			
#			$BufferTimeEnd = [datetime]::ParseExact($BufferTimeEndString,"MM.dd.yyyy-HH.mm",$null)
#			           
#			$BufferTimeEnd = Get-Date $BufferTimeEnd -format "dd.MM.yyyy-HH.mm"
#			
#			$BufferTimeEndString = $BufferTimeEnd.ToString()
#			
#			$FormattedDateTimeStringElement = New-Object -TypeName PSObject
#			$FormattedDateTimeStringElement | Add-Member -Type NoteProperty -Name StreamTimeIntervalBegin -Value "$BufferTimeBeginString"
#			$FormattedDateTimeStringElement | Add-Member -Type NoteProperty -Name StreamTimeIntervalEnd -Value "$BufferTimeEndString"
#			$FormattedDateTimeStringMassive += $FormattedDateTimeStringElement
#			
#			$BufferTimeBeginMassive = $BufferTimeBeginString
#			$BufferTimeEndMassive   = $BufferTimeEndString
#			
#			if($Count -eq 0)	{
#			
#				$BeginTimeString1 = $BufferTimeBeginString
#				$EndTimeString1 = $BufferTimeEndString
#			
#			}
#			
#			if($Count -eq 1)	{
#			
#				$BeginTimeString2 = $BufferTimeBeginString
#				$EndTimeString2 = $BufferTimeEndString
#			
#			}
#			
#			#-----------------------------------------------------------------
#			
#			Write-Host "BufferTimeBeginString: $BufferTimeBeginString"
#			Write-Host "BufferTimeEndString: $BufferTimeEndString"
#			Write-Host "BufferTimeBeginMassive: $BeginTimeString1"
#			Write-Host "BufferTimeEndMassive: $EndTimeString1"
#			
#			if($Debug4Parm)	{
#				
#				Write-Host -background "white" -foreground "black" "Debug4Parm is set! Exit."
#				exit
#			
#			}
#			
#			$Count++
#			
#		}
#		
#		try	{
#			
#			$Definition = Get-Content Function:\ParallelReplica -ErrorAction Stop
#			$Args = "0 $FullPathToDirectoryOrFile $BeginTimeString1 $EndTimeString1 $SecLogParm $ArchLogDirParm 0 0 0 0 0"
#			echo "1"
#			$SessionStateFunction = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList @(0,$FullPathToDirectoryOrFile,$BeginTimeString1,$EndTimeString1,$SecLogParm,$ArchLogDirParm,0,0,0,0,0) , $Definition
#			echo "2"
#			$InitialSessionState.Commands.Add($SessionStateFunction)
#			echo "3"
#			$RunspacePool = [runspacefactory]::CreateRunspace(1,5,$InitialSessionState)
#						
#			$Runspace = [runspacefactory]::CreateRunspace()
#			$PowerShell = [powershell]::Create()
#			$PowerShell.runspace = $Runspace
#			$Runspace.Open()
#		
#			[void]$PowerShell.AddScript({
#				
#				Write-Host $SecLogParm
#				ParallelReplica
#				
#			}).AddArgument($Args)
#			
#			$AsyncObject = $PowerShell.BeginInvoke()
#			
#		}	catch	{
#			
#			Write-Host "Exception!"
#			Write-Host -foreground "red" $_.Exception.Message
#		
#		}
#		
#		#ParallelReplica 0 $WorkflowMask $BeginTimeString1 $EndTimeString1 $SecLogParm $ArchLogDirParm 0 0 0 0 0
#	
#		#Parallel-Section $MaskParm $FormattedDateTimeStringMassive $SecLogParm $ArchLogDirParm
#		
#		#$PP1 = Invoke-Command -scriptblock {ParallelReplica 0 $WorkflowMask $BeginTimeString1 $EndTimeString1 $SecLogParm $ArchLogDirParm 0 0 0 0 1}
#		#$PP2 = Invoke-Command -scriptblock {ParallelReplica 0 $WorkflowMask $BeginTimeString2 $EndTimeString2 $SecLogParm $ArchLogDirParm 0 0 0 0 1}
#		#$pp1 = start-job -name pp1 -scriptblock {ParallelReplica} -ArgumentList 0,$WorkflowMask,$BeginTimeString2,$EndTimeString2,$SecLogParm,$ArchLogDirParm,0,0,0,0,1
#		#start-job -name pp2 -scriptblock {ParallelReplica 0 $WorkflowMask $BeginTimeString2 $EndTimeString2 $SecLogParm $ArchLogDirParm 0 0 0 0 1}
#		
#				
#		
#	}
	
	exit

}

if(!$DisableDebugOutput)	{	
	
	echo "Count of Log with necessary time intervals inside = $CountLog`n"
	
}
#$SecondTimeLimit = [datetime]"$"

#$BeginTime = (get-date) - (new-timespan -day $DeltaDayBegin -hour $DeltaHourBegin -min $DeltaMinutesBegin)
#$EndTime = (get-date) - (new-timespan -day $DeltaDayEnd -hour $DeltaHourEnd -min $DeltaMinutesEnd)

#$FormattedBeginTime = $BeginTime.AddDate();

#$CurrentTime = get-date

#echo "TimeInterval: From $BeginTime to $EndTime"

#$HTMLOutFile = "C:\Users\vlozhnikov\Desktop\Scripts\PowerShell\OUT\FilesCreatedFrom-$BeginTime-To-$.html"

$CountOfRecords = 0

#$CountEventsInLog = Get-WinEvent @{Path=$LogFileNameSelector;StartTime=$BeginTime;EndTime=$EndTime} 

#foreach ($Event in $CountEventsInLog)	{
#
#	$CountOfRecords++
#
#}

$MinTime = 0;
$MinTimeCount = 0;
$MaxTime = 0;
$MaxTimeCount = 0;
$Bool = 1

$FilteredEvents = @()

$iteration = 0

[PSObject]$LogFileNameMassiveObjects = @()

foreach($LogFileNameSelector in $LogFileNameMassive)	{

	$LogFileNameSelectorObject = New-Object -TypeName PSObject
	$LogFileNameSelectorObject | Add-Member -Type NoteProperty -Name Filename -Value "$LogFileNameSelector"
	$LogFileNameSelectorObject | Add-Member -Type NoteProperty -Name TimeBegin -Value $($BeginTime[$iteration])
	$LogFileNameSelectorObject | Add-Member -Type NoteProperty -Name TimeEnd -Value $($EndTime[$iteration])
	$LogFileNameMassiveObjects += $LogFileNameSelectorObject
	
	if(!$DisableDebugOutput)	{	
	
		Write-Host "$LogFileNameSelectorObject :  $($BeginTime[$iteration]) - $($EndTime[$iteration])"
	
	}
	
	$iteration++
	
}

if(!$DisableDebugOutput)	{	

	Write-Host " -- -- "
	
foreach($Element in $LogFileNameMassiveObjects)	{
	
	Write-Host "$($Element.Filename) : $($Element.TimeBegin) - $($Element.TimeEnd)"
	
}

}
#if($Debug2)	{
#
#	Write-Host -background "white" -foreground "blue" "Debug2 is set! Exit"
#	exit
#
#}

try	{

	ForEach($LogFileNameSelectorObject in $LogFileNameMassiveObjects)	{
		
		Write-Host "Filtering events with ID = 4660 ... [ $($LogFileNameSelectorObject.TimeBegin) - $($LogFileNameSelectorObject.TimeEnd)]"

		$Events = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{Path=$($LogFileNameSelectorObject.Filename);LogName="Security";ID=4660;StartTime=$($LogFileNameSelectorObject.TimeBegin);EndTime=$($LogFileNameSelectorObject.TimeEnd)} | select TimeCreated,@{n="Rec_";e={([xml]$_.ToXml()).Event.System.EventRecordID }} | sort Rec_
		
		Write-Host "Filtering events with ID = 4663 with time difference about 2 sec relatively to ID = 4660 ..."
		
		foreach($Event in $Events)	{
			
			$PrevEvent = $Event.Rec_
			$PrevEvent = $PrevEvent - 1
		
			$TimeEvent = $Event.TimeCreated
			$TimeSpan = (new-timespan -sec 1)
			$TimeEventStart = $TimeEvent - $TimeSpan
			$TimeEventEnd   = $TimeEvent + $TimeSpan
			
			#Write-Host "$($Event.TimeCreated) : $TimeEvenStart - $TimeEventEnd"
			
			$BodyOfEvent = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{Path=$($LogFileNameSelectorObject.Filename);LogName="Security";ID=4663;StartTime=$TimeEventStart;EndTime=$TimeEventEnd} |where {([xml]$_.ToXml()).Event.System.EventRecordID -match "$PrevEvent"}|where{ ([xml]$_.ToXml()).Event.EventData.Data |where {$_.name -eq "ObjectName"}|where {($_.'#text') -notmatch ".*tmp"} |where {($_.'#text') -notmatch ".*~lock*"}|where {($_.'#text') -notmatch ".*~$*"}} |select TimeCreated, @{n="FileName";e={([xml]$_.ToXml()).Event.EventData.Data | ? {$_.Name -eq "ObjectName"} | %{$_.'#text'}}},@{n="UserName";e={([xml]$_.ToXml()).Event.EventData.Data | ? {$_.Name -eq "SubjectUserName"} | %{$_.'#text'}}}

			if($BodyOfEvent)	{
				
				if($BodyOfEvent -match $FullPathToDirectoryOrFile)	{
				
					#$FilteredEvent = New-Object -TypeName PSObject
					#$FilteredEvent | Add-Member -type NoteProperty -name TimeCreated_ -value $($BodyOfEvent.TimeCreated)
					#$FilteredEvent | Add-Member -type NoteProperty -name FileName -value $($BodyOfEvent.FileName)
					#$FilteredEvent | Add-Member -type NoteProperty -name UserName -value $($BodyOfEvent.UserName)
					
					$FilteredEvents += $BodyOfEvent
					
					Write-Host -NoNewLine -foreground "Green" "."
					Write-Host " $TimeEvent [ $($BodyOfEvent.UserName) ] : $($BodyOfEvent.FileName)"
					
				}	else	{
				
				
				Write-Host -NoNewLine -foreground "Yellow" "."
				Write-Host " $TimeEvent [ $($BodyOfEvent.UserName) ] : $($BodyOfEvent.FileName)"

				
				}
				
			}	else	{
	
			Write-Host -NoNewLine -foreground "Magenta" "."
			Write-Host " $TimeEvent : File not match source mask. Temporary Word - [ .*~$* ], Lock - [ .*~lock* ] or tmp - [ .*tmp ] "

	
			}
			
		}
		
	}
	
    }   catch    {
    
        Write-Host -foreground "yellow" "Problem in parsing and searching. Exit Stream."

    }

	if($FilteredEvents)	{
	
		if(!$DisableDebugOutput)	{	
		
			Write-Host "`nWrite events with suitable mask to HTML in OUT/ directory"
		
		}
	    
        try    {
    
		$Filename = "$PSScriptRoot\Temp\$GlobalIntervalBegin-$GlobalIntervalEnd\FilesDeletedFrom-$($FirstDateTimeLimit.ToString("dd.MM.yyyy-HH.mm"))-To-$($SecondDateTimeLimit.ToString("dd.MM.yyyy-HH.mm")).html"
		$FilteredEvents | Sort-Object -property TimeCreated | ConvertTo-Html -As TABLE -Property TimeCreated,UserName,FileName | Out-File -FilePath $Filename

        #echo $FilteredEvents

   		}    catch   {
            
            Write-Host -ForegroundColor "Red" "Err in writing HTML!"
           
        }



	}	else	{
		
		#if(!$DisableDebugOutput)	{	
		
			Write-Host -NoNewLine -foreground "Yellow" "`nNo files with "
			Write-Host -NoNewLine -foreground "Red" "$FullPathToDirectoryOrFile"
			Write-Host -foreground "Yellow" " mask!."
		
		#}
	}
	
#}	catch	{

#	Write-Host -foreground "Yellow" "Exit! Probably, those EVENTS NOT EXIST in this log in this time interval!`n"

#}

if(!$DisableDebugOutput)	{	

	Write-Host "Counting filtered records..."

}

$CountOfRecords = 0

foreach ($Event in $Events)	{
	
	$CountOfRecords++
		
	#echo $Event
	
#	if ($Event -match "$FullPathToDirectoryOrFile")	{
	
#	$MatchRecords = $MatchRecords + $Event.TimeCreated + "`t" + $Event.Ð¤Ð°Ð¹Ð»_ + "`t" + $Event.ÐŸÐ¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÐµÐ»ÑŒ_ + "`n"
		
#	}

}

if(!$FullPathToDirectoryOrFile)		{

	if(!$DisableDebugOutput)	{	
		
		echo "CountOfRecords (Filtered by ID=4660 + ID=4663 (Delete File) and selecting files without mask): $CountOfRecords"
		
	}
	#echo $Events
	
}	else	{
	
	if(!$DisableDebugOutput)	{	
	
		Write-Host -NoNewLine "CountOfRecords (Filtered by ID=4660 + ID=4663 (Delete File) and" 
		Write-Host -NoNewLine -foreground "red" "`t$FullPathToDirectoryOrFile".ToUpper()
		Write-Host " line entry): $CountOfRecords"
	}
}

if(!$DisableDebugOutput)	{	
	
	Write-Host -foreground "Green" "`n ------------------------ STREAM END! ------------------------ `n"

}

$EndRuntime = (Get-Date).Second

$TimeRunInSec = $($EndRuntime - $StartRuntime)
$TimeRunInDayHourMinutes = $TimeRunInSec -replace '^\d+?\.'

if(!$DisableDebugOutput)	{	
	
	echo "Time to RUN: $TimeRunInDayHourMinutes sec."
	
}

#return "Complete!"

#}

#$GlobalFirstEventsLog += ParallelReplica "-LogTimeListParm" "" 0 0 $SecLogParm $ArchLogDirParm 0 0 "-EnableReturnFirstEventsObjectParm" 0

#&ParallelReplica 0 "" $btParm $etParm $SecLogParm $ArchLogDirParm 0 0 0 0 1