$StorageAccountKey=""
$sourceFileRootDirectory="C:\Shara"
$StorageAccountName="trfrmfileshafeandblobs"
$ContainerName="blobs"
$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$container = Get-AzureStorageContainer -Name $ContainerName -Context $ctx

 if ($container) {
        $filesToUpload = Get-ChildItem $sourceFileRootDirectory -Recurse -File

        foreach ($x in $filesToUpload) {
            $blobName = ($x.fullname.Substring($x.PSDrive.Root.Length)).Replace("\", "/")

            Set-AzureStorageBlobContent -File $x.fullname -Container $container.Name -Blob $blobName -Context $ctx -Force:$Force 
        }
}