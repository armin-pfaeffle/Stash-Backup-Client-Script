Bitbucket Server Client Script
==========================

This simple script is for running [Bitbucket Server Backup Client](https://marketplace.atlassian.com/plugins/com.atlassian.stash.backup.client) on a Windows computer. In my case, I wanted a script that is callable by a Windows task to run in background, so my server can run backup and notify me by E-Mail about the result.

## Contents

1. [Overview](#overview)
	1. [Functionality/Features](#functionalityfeatures)
	2. [What does this script exactly do?](#what-does-this-script-exactly-do)
2. [Installation](#installation)
3. [Run script as Windows task](#run-script-as-windows-task)
1. [FAQ](#faq)
1. [Author](#author)


# Overview

## Functionality/Features

* Configurable script for running Bitbucket Server Backup Client
* Waitung for Bitbucket Server service to run
* Send notification mail before starting and after finishing script (with backup log, optional)
* Simple mail credential configuration with test mail

## What does this script exactly do?

First of all the script loads the `configuration.ps1` file, so prepare that before using the script! After that it ensures that there is a `log`directory so the script can wirte log files ‒ one log file for each day the script is executed. In the next step it checks for file existance of `backup-client.mail-credential` file where mail credential are saved to ‒ if `SendMailAfterBackup` parameter in configuration is set to `$FALSE` then there must not mail credential. If file does not exist the script asks for mail credential, saves it and sends a test mail. If sending fails, credential file is deleted. If everything is fine script quits, so you have to run it again to execute backup.

After the initialization the script sends a "Starting backup" mail, so you know that your server is running the backup. Then it checks for Atlassian Bitbucket Server service and that it is running, which is necessary for executing backup. If there is any problem you will receive an E-mail with a short problem description in the subject. If everything is fine the backup client is executed, after which you will receive an E-Mail with the report. Furthermore the complete output is written to a daily log file.


# Installation

1. Put the script files `run-backup-client.ps1` and `configuration.ps1` anywhere on your computer.
2. Ensure that it has write rights to the directory because it writes log files.
3. Open `configuration.ps1` modify it for you needs. If you don't want to receive reports via E-Mail set `SendMailAfterBackup` to `$FALSE` and you can ignore the `Mail`section.
4. If you want to receive E-Mails you have to run the script via Windows PowerShell before you can use it as backup script. The reason for this is that it asks you for username and password for the mail server and stores this data to a file `backup-client.mail-credential`. So script can access mail credential and send mail automatically. After entering credential you receive a test mail and the script quits.
5. Now you can run the script manually by executing it via Windows PowerShell, or you can add a Windows task.

# Run script as Windows task
How you can add a new task [is described here](http://www.sevenforums.com/tutorials/12444-task-scheduler-create-new-task.html). The important things are to set the right parameters as application ‒ please adjust the pathes!

```
// Program/script:
C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe

// Add arguments (optional):
-NoLogo -NonInteractive -File "C:\Atlassian\Backup Client Script\run-backup-client.ps1"

// Start in (optional):
C:\Atlassian\Backup Client Script
```


# FAQ

1. Can I send the notification mails to more than one e-mail address?

Yes you can! In the `configuration.ps1` you can see the option `To` in the `Mail` group. There you can set at least one e-mail address or set more than one by separating them via a comma, e.g. the line can look like `"To" = "first@example.com, second@example.com, third@example.com";`.


When you habe any further questions, please contact me via E-Mail [mail@armin-pfaeffle.de](mailto:mail@armin-pfaeffle.de)!


### Author

Armin Pfäffle ‒ [www.armin-pfaeffle.de](http://www.armin-pfaeffle.de) ‒ [mail@armin-pfaeffle.de](mailto:mail@armin-pfaeffle.de)
