###################################################################################################
#                                                                                                 #
#  Script for Executing Stash Backup Client                                                       #
#                                                                                                 #
#  Version: 0.4                                                                                   #
#  Date: 19.08.2014                                                                               #
#  Author: Armin Pfäffle                                                                          #
#  E-Mail mail@armin-pfaeffle.de                                                                  #
#  Web: http://www.armin-pfaeffle.de                                                              #
#                                                                                                 #
###################################################################################################


# Include configuration
. .\configuration.ps1


#
# Logs a message to the log file and outputs it if $echo is $TRUE.
#
function Log($text, $withTimestamp = $TRUE, $echo = $TRUE)
{
	$line = ""
	if ($text) {
		$line = [string]$text
		if ($withTimestamp) {
			$now = Get-Date
			$line = "{0} {1}" -f $now, $line
		}
	}

	$line >> $logFilename
	if ($echo) {
		Write-host $line
	}
}

#
# Ensures that there is log directory given by $logDirectory. If folder does not
# exist it is created.
#
function EnsureLogDirectory
{
	if( -not (Test-Path $logDirectory) )
	{
		New-Item $logDirectory -type directory
	}
}

#
# Checks if mail credential file exists; if not asks user for credential and saves given
# information in credential file. Password is encrypted.
#
function EnsureMailCredentialFile
{
	If (!(Test-Path $mailCredentialFilename))
	{
		Log "Ask for mail credential"
		try {
			$credential = Get-Credential
		} Catch {
			$ErrorMessage = $_.Exception.Message
			Write-Error $ErrorMessage
			Exit
		}
		
		Log "Create mail credential file"
		$encrytpedPassword = ConvertFrom-SecureString $credential.password
		$line = "{0}|{1}" -f $credential.username, $encrytpedPassword
		$line > $mailCredentialFilename
		
		Log "Send test mail"
		$result = SendMail $configuration["Mail"]["Subject"]["Test"] -ErrorAction Stop
		if (!$result) {		
			Log "Delete credential file because of an error while sending mail. Please check you credential!"
			Remove-Item $mailCredentialFilename
		}
		
		Exit
	}
}

#
# Returns date from mail credential file and returns PSCredential instance.
#
function GetMailCredential
{
	Log "Load mail credential"

	$line = Get-Content $mailCredentialFilename
	$rawCredential = $line.Split("|")
	$username = $rawCredential[0]
	$password = ConvertTo-SecureString $rawCredential[1]
	$credential = New-Object System.Management.Automation.PSCredential $username, $password
	Return $credential
}

#
# Sends mail with given subject. Adds additional text to body if $additionalBody is set.
#
function SendMail($subject, $additionalBody = "")
{
	Log ("Sending mail '{0}'" -f $subject)

	$credential = GetMailCredential

	# Gather all needed server information
	$mail = $configuration["Mail"];
	$from = $mail["From"]
	$to = $mail["To"]
	$server = $mail["Server"]

	# Obtain subject and body
	if ($mail["Subject"]["Prefix"]) {
		$subject = "{0} {1}" -f $mail["Subject"]["Prefix"], $subject
	}

	$currentTimestamp = Get-Date
	$body = "Skript startet: {0}`nSkript ended: {1}" -f $scriptStartedTimestamp, $currentTimestamp
	if ($additionalBody) {
		$body = $body + "`n`n" + $additionalBody
	}

	# Ensure that there is no problem with certificates...
	[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }

	Try {
		Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer $server -Credential $credential -UseSsl -ErrorAction Stop
		Return $TRUE
	} Catch {
		Write-Error $_.Exception
		Return $FALSE
	}
	
}

#
# Waits for service to run. If service needs to long to start that FALSE is returned.
# If service does not start at all, FALSE is returned.
#
function WaitForRunningService
{
	$startTimestamp = Get-Date
	$service = Get-Service -Name $configuration["ServiceName"]
	While ($service.Status -ne "Running") {
		$now = Get-Date
		if ((New-TimeSpan -Start $startTimestamp -End $now).TotalSeconds -gt $configuration["MaxSecondsWaitingForService"]) {
			Return $FALSE
		}
		Start-Sleep -Seconds 5
		$service = Get-Service -Name $configuration["ServiceName"]
	}
	Return $TRUE
}

#
# Changes working directory to Stash Backup Client directory, then runs the Stash Backup Client
# and finally returns to the original working directory.
#
function RunStashBackup
{
	Log "Run Stash Backup Client"
	Log ""

	$stash = $configuration["Stash"]

	# Change to working directory and execute application
	if ($stash["WorkingDirectory"]) {
		cd $stash["WorkingDirectory"]
	}
	#Invoke-Expression $stash["Executable"] 2>&1 | Tee-Object -Variable output
	$output = (Invoke-Expression $stash["Executable"] 2>&1) | Out-String

	Log $output $FALSE

	# Restore working directory
	cd $currentDirectory

	Return $output
}


###################################################################################################


$scriptStartedTimestamp = Get-Date
$mailCredentialFilename = ".\stash-backup.mail-credential"

$currentDirectory = $(get-location)
$logDirectory = "{0}\log" -f $currentDirectory

$today = Get-Date -UFormat "%Y%m%d"
$logFilename = "{0}\{1}.log" -f $logDirectory, $today


EnsureLogDirectory

if ($configuration["SendMailAfterBackup"]) {
	EnsureMailCredentialFile
}

$service = Get-Service -Name $configuration["ServiceName"]
if ($service)
{
	Log ("Service '{0}' found" -f $configuration["ServiceName"])

	$serviceIsAvailable = WaitForRunningService
	if ($serviceIsAvailable) {
		Log "Service is running"
		Log "Starting Stash Backup Client"

		$mailOutput = RunStashBackup

		if ($configuration["SendMailAfterBackup"]) {
			if (!$configuration["Mail"]["AddLogToBody"]) {
				$mailOutput = ""
			}
			if ($mailOutput -match "Exception") {
				$subject = $configuration["Mail"]["Subject"]["Error"]
			} Else {
				$subject = $configuration["Mail"]["Subject"]["Success"]
			}
			SendMail $subject $mailOutput
		}
	} Else {
		Log "Service is not running, needs to long to start or is stopped and does not start"
		if ($configuration["SendMailAfterBackup"]) {
			SendMail $configuration["Mail"]["Subject"]["ServiceNotRunning"]
		}
	}
}
Else
{
	Log ("Service '{0}' not found" -f $configuration["ServiceName"])
	if ($configuration["SendMailAfterBackup"]) {
		SendMail $configuration["Mail"]["Subject"]["ServiceNotFound"]
	}
}
