
$configuration = @{
	"Stash" = @{
		"Executable" = "java -jar -noverify stash-backup-client.jar";
		"WorkingDirectory" = "C:\Atlassian\Stash\stash-backup-client-1.3.0";
	};
	"ServiceName" = "AtlassianStash";
	"MaxSecondsWaitingForService" = 300;

	"SendMailAfterBackup" = $TRUE;
	"Mail" = @{
		"From" = "from@example.com";
		"To" = "to@example.com";
		"Server" = "mail.example.com";

		"Subject" = @{
			"Prefix" = "[Stash Backup]";

			"Success" = "Successful";
			"Error" = "Error";
			"ServiceNotFound" = "Service not found";
			"ServiceNotRunning" = "Service is not running";
		};
		"AddLogToBody" = $TRUE;
	};
}
