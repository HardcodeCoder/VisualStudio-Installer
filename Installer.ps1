#Get current user context
$CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())

#Check user is running the script is member of Administrator Group
if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
{
	Write-host "Script is running with Administrator privileges!" -f Green
}
else
{
	#Create a new Elevated process to Start PowerShell
	$ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";

	# Specify the current script path and name as a parameter
	$ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"

	#Set the Process to elevated
	$ElevatedProcess.Verb = "runas"

	#Start the new elevated process
	[System.Diagnostics.Process]::Start($ElevatedProcess)

	#Exit from the current, unelevated, process
	Exit
}


# Enterprise 
$VS_ENT_URL = "https://aka.ms/vs/17/release/vs_enterprise.exe"

# Professional
$VS_PRO_URL = "https://aka.ms/vs/17/release/vs_professional.exe"


#Don't touch these variables, for script usage
$DOWNLOAD_LOCATION = "$env:TEMP\vs_automated_installer.exe"
$CONFIG_PATH = "$env:TEMP\installer_config.vsconfig"
$URL = ""
$EDITION = ""
$PRODUCT_ID = ""


# Delete downloaded files
function CleanUp {
	if (Test-Path $DOWNLOAD_LOCATION) {
		Remove-Item $DOWNLOAD_LOCATION
	}
	if (Test-Path $CONFIG_PATH) {
		Remove-Item $CONFIG_PATH
	}
}


function Download-BootStrapper {
	CleanUp
	Write-Host ""
	Write-Host "Downloading Visual Studio $EDITION bootstrapper..."
	Invoke-WebRequest -URI $URL -OutFile $DOWNLOAD_LOCATION
	Write-Host "Download complete."
}


function Prepare-Config {
	$components = @'
{
  "version": "1.0",
  "components": [
    "Microsoft.VisualStudio.Component.Roslyn.Compiler",
    "Microsoft.Component.MSBuild",
    "Microsoft.VisualStudio.Component.Roslyn.LanguageServices",
    "Microsoft.VisualStudio.Component.MSODBC.SQL",
    "Microsoft.VisualStudio.Component.MSSQL.CMDLnUtils",
    "Microsoft.VisualStudio.Component.SQL.LocalDB.Runtime",
    "Microsoft.VisualStudio.Component.SQL.CLR",
    "Microsoft.VisualStudio.Component.CoreEditor",
    "Microsoft.VisualStudio.Workload.CoreEditor",
    "Microsoft.Net.Component.4.8.SDK",
    "Microsoft.Net.Component.4.7.2.TargetingPack",
    "Microsoft.Net.ComponentGroup.DevelopmentPrerequisites",
    "Microsoft.VisualStudio.Component.TypeScript.TSServer",
    "Microsoft.VisualStudio.Component.TypeScript.SDK.4.9",
    "Microsoft.VisualStudio.ComponentGroup.WebToolsExtensions",
    "Microsoft.VisualStudio.Component.JavaScript.TypeScript",
    "Microsoft.VisualStudio.Component.JavaScript.Diagnostics",
    "Microsoft.VisualStudio.Component.TextTemplating",
    "Component.Microsoft.VisualStudio.RazorExtension",
    "Microsoft.VisualStudio.Component.IISExpress",
    "Microsoft.VisualStudio.Component.NuGet",
    "Microsoft.VisualStudio.Component.Common.Azure.Tools",
    "Microsoft.Component.ClickOnce",
    "Microsoft.VisualStudio.Component.ManagedDesktop.Core",
    "Microsoft.VisualStudio.Component.SQL.SSDT",
    "Microsoft.VisualStudio.Component.SQL.DataSources",
    "Component.Microsoft.Web.LibraryManager",
    "Component.Microsoft.WebTools.BrowserLink.WebLivePreview",
    "Microsoft.VisualStudio.ComponentGroup.Web",
    "Microsoft.NetCore.Component.Runtime.6.0",
    "Microsoft.NetCore.Component.Runtime.7.0",
    "Microsoft.NetCore.Component.SDK",
    "Microsoft.VisualStudio.Component.FSharp",
    "Microsoft.ComponentGroup.ClickOnce.Publish",
    "Microsoft.NetCore.Component.DevelopmentTools",
    "Microsoft.VisualStudio.Component.FSharp.WebTemplates",
    "Microsoft.VisualStudio.Component.DockerTools",
    "Microsoft.NetCore.Component.Web",
    "Microsoft.VisualStudio.Component.WebDeploy",
    "Microsoft.VisualStudio.Component.AppInsights.Tools",
    "Microsoft.VisualStudio.Component.Web",
    "Microsoft.Net.Component.4.8.TargetingPack",
    "Microsoft.Net.ComponentGroup.4.8.DeveloperTools",
    "Microsoft.VisualStudio.Component.AspNet45",
    "Microsoft.VisualStudio.Component.AspNet",
    "Component.Microsoft.VisualStudio.Web.AzureFunctions",
    "Microsoft.VisualStudio.ComponentGroup.AzureFunctions",
    "Microsoft.VisualStudio.Component.Debugger.Snapshot",
    "Microsoft.VisualStudio.ComponentGroup.Web.CloudTools",
    "Microsoft.VisualStudio.Component.IntelliTrace.FrontEnd",
    "Microsoft.VisualStudio.Component.DiagnosticTools",
    "Microsoft.VisualStudio.Component.EntityFramework",
    "Microsoft.VisualStudio.Component.LiveUnitTesting",
    "Microsoft.VisualStudio.Component.Debugger.JustInTime",
    "Component.Microsoft.VisualStudio.LiveShare.2022",
    "Microsoft.VisualStudio.Component.WslDebugging",
    "Microsoft.VisualStudio.Component.IntelliCode",
    "Microsoft.VisualStudio.Component.TeamsFx",
    "Microsoft.VisualStudio.Component.Wcf.Tooling",
    "Microsoft.Net.Component.4.6.2.TargetingPack",
    "Microsoft.Net.Component.4.7.TargetingPack",
    "Microsoft.Net.Component.4.7.1.TargetingPack",
    "Microsoft.VisualStudio.Component.ClassDesigner",
    "Microsoft.VisualStudio.Component.DependencyValidation.Enterprise",
    "Microsoft.VisualStudio.Workload.NetWeb",
    "Microsoft.VisualStudio.Component.Azure.ClientLibs",
    "Microsoft.VisualStudio.ComponentGroup.Azure.Prerequisites",
    "Microsoft.VisualStudio.Component.Azure.ResourceManager.Tools",
    "Microsoft.VisualStudio.ComponentGroup.Azure.ResourceManager.Tools",
    "Microsoft.VisualStudio.Component.Azure.AuthoringTools",
    "Microsoft.VisualStudio.Component.Azure.Waverton.BuildTools",
    "Microsoft.VisualStudio.Component.Azure.Compute.Emulator",
    "Microsoft.VisualStudio.Component.Azure.Waverton",
    "Microsoft.VisualStudio.ComponentGroup.Azure.CloudServices",
    "Microsoft.VisualStudio.Component.Azure.ServiceFabric.Tools",
    "Microsoft.VisualStudio.Component.Azure.Powershell",
    "Microsoft.VisualStudio.Workload.Azure",
    "Microsoft.VisualStudio.Component.ManagedDesktop.Prerequisites",
    "Microsoft.VisualStudio.Component.DotNetModelBuilder",
    "Microsoft.ComponentGroup.Blend",
    "Microsoft.VisualStudio.Workload.ManagedDesktop",
    "Microsoft.VisualStudio.Workload.Data",
    "Microsoft.Component.CodeAnalysis.SDK",
    "Microsoft.VisualStudio.Component.Workflow",
    "Microsoft.VisualStudio.Component.Git",
    "Microsoft.VisualStudio.Component.LinqToSql",
    "Microsoft.Net.Component.4.6.1.TargetingPack"
  ]
}
'@
	$null = New-Item "$CONFIG_PATH"
	Set-Content "$CONFIG_PATH" $components -NoNewLine
}

# Perform download and Installation
function Install {
	try {
		Write-Host ""
		Write-host "Installation Started. Please wait..."
		Download-BootStrapper
		Write-Host "Preparing Configuration..."
		Write-Host ""
		Prepare-Config
		Write-Host "Installing..."
		$file_path = "$DOWNLOAD_LOCATION"
		$args = "--norestart --passive --installWhileDownloading --nocache --wait --config ""$CONFIG_PATH"""
		$process = Start-Process -FilePath $file_path -ArgumentList $args -Wait -PassThru
		Write-Host "Installation Completed with Exit Code: $($process.ExitCode)"
	}
	catch {
		Write-Host $_
		Write-Host ""
		Write-Host $_.ScriptStackTrace
	}
}


# Uninstall any existing installation
function Uninstall {
	$FORECE = Read-Host "Use force Uninstallation? (y/N)"

	Write-host ""
	Write-Host "Uninstalling $EDITION edition with force option: $FORECE"
	Download-BootStrapper
	
	Write-host "Uninstall started. Please wait..."
	$file_path = "$DOWNLOAD_LOCATION"
	$args = "uninstall", "--passive", "--productId $PRODUCT_ID", "--channelId  VisualStudio.17.Release", "--wait"
	$process = Start-Process -FilePath $file_path -ArgumentList $args -Wait -PassThru
	
	if ($FORCE -eq "y") {
		#Get-ChildItem -Path "C:\Program Files (x86)\Microsoft Visual Studio" -Include *.* -Recurse | foreach { $_.Delete()}
		#Get-ChildItem -Path "C:\Program Files\Microsoft Visual Studio" -Include *.* -Recurse | foreach { $_.Delete()}
		Remove-Item "C:\Program Files (x86)\Microsoft Visual Studio" -Recurse -Force
		Remove-Item "C:\Program Files\Microsoft Visual Studio" -Recurse -Force
	}
	
	Write-Host "Uninstall completed with Exit code: $($process.ExitCode)"
}


# Main script starts here
Write-Host "Welcome to Automated VS Installer" -f Green
Write-Host ""
Write-Host "Choose an Edition"
Write-Host "Professional: p"
Write-Host "Enterprise: e"
$edition = Read-Host -Prompt "Enter your choice"
Write-Host ""

if ($edition -eq "p") {
	$EDITION = "Professional"
	$URL = "$VS_PRO_URL"
}
elseif ($edition -eq "e"){
	$EDITION = "Enterprise"
	$URL = "$VS_ENT_URL"
}
else {
	Write-Host "Invalid Selection. Exiting in 5 seconds"
	Start-Sleep -Seconds 5
	Exit
}


$PRODUCT_ID = "Microsoft.VisualStudio.Product.$EDITION"

Write-Host ""
Write-Host "Choose an operation:"
Write-Host "Install: i"
Write-Host "Uninstall: u"
$operation = Read-Host -Prompt "Enter your choice"
Write-Host ""


if ($operation -eq "i") {
	Install
}
elseif ($operation -eq "u"){
	Uninstall
}
else{
	Write-Host "Invalid Selection. Exiting in 5 seconds"
	Start-Sleep -Seconds 5
	Exit
}


CleanUp
Read-Host -Prompt "Press any key to exit..."