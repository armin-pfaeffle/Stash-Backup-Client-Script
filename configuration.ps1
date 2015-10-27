
$configuration = @{
	"Bitbucket Server" = @{
		"Executable" = "java -jar -noverify bitbucket-backup-client.jar";
		"WorkingDirectory" = "C:\Atlassian\Bitbucket\bitbucket-backup-client-2.0.0";
	};
	"ServiceName" = "AtlassianBitbucket";
	"MaxSecondsWaitingForService" = 300;
	
	"SendMailBeforeBackup" = $TRUE;
	"SendMailAfterBackup" = $TRUE;
	"Mail" = @{
		"From" = "from@example.com";
		"To" = "to@example.com";
		"Server" = "mail.example.com";

		"Subject" = @{
			"Prefix" = "[Bitbucket Server Backup]";

			"Test" = "Testing mail credential";
			"Start" = "Starting backup";
			"Success" = "Successful";
			"Error" = "Error";
			"ServiceNotFound" = "Service not found";
			"ServiceNotRunning" = "Service is not running";
		};
		"AddLogToBody" = $TRUE;
	};
}
