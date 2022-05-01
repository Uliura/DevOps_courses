[string]$key=$args
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider NuGet -Force;
Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module Az -Confirm:$False -Force
New-Item -Path "C:\AzCopy" -ItemType Directory
Set-Location -Path C:\AzCopy
Invoke-WebRequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -OutFile AzCopy.zip -UseBasicParsing
Expand-Archive ./AzCopy.zip ./AzCopy -Force
Get-ChildItem ./AzCopy/*/azcopy.exe | Copy-Item -Destination "./azcopy.exe"
New-Item -Path "C:\Shara" -ItemType Directory
$script = '
$StorageAccountKey = "QAZWSX"
$sourceFileRootDirectory="C:\Shara"
$StorageAccountName="trfrmfileshafeandblobs"
$ContainerName="blobs"
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$container = Get-AzStorageContainer -Name $ContainerName -Context $ctx

 if ($container) {
        $filesToUpload = Get-ChildItem $sourceFileRootDirectory -Recurse -File

        foreach ($x in $filesToUpload) {
            $blobName = ($x.fullname.Substring($x.PSDrive.Root.Length)).Replace("\", "/")

            Set-AzStorageBlobContent -File $x.fullname -Container $container.Name -Blob $blobName -Context $ctx -Force:$Force 
        }
}
'
$script | out-file C:\AzCopy\script.ps1
(Get-Content C:\AzCopy\script.ps1 -Raw) -Replace "QAZWSX", $key | Set-Content C:\AzCopy\script.ps1
$User= "NT AUTHORITY\SYSTEM"
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File C:\AzCopy\script.ps1"
$taskTrigger = New-ScheduledTaskTrigger -Daily -At 3PM
$taskName = "ExportAppLog"
Register-ScheduledTask -TaskName $taskName -Trigger $taskTrigger -User $User -Action $taskAction -RunLevel Highest -Force
