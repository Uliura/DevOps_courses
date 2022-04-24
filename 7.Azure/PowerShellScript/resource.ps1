Clear-Host
Connect-AzAccount
$azureSubscriptions = Get-AzSubscription

$azureSubscriptionCounter = 1
foreach ($azureSubscription in $azureSubscriptions) {
    Write-Output "($azureSubscriptionCounter) $($azureSubscription.Name)"
    $azureSubscriptionCounter++;
}

$subscriptionNumber = Read-Host 'Please choose subscription'

Select-AzSubscription -SubscriptionName $azureSubscriptions[$subscriptionNumber - 1].Name

$azureResourceGroups = Get-AzResourceGroup | Select-Object ResourceGroupName

$azureResourceGroupCounter = 1
foreach ($azureResourceGroup in $azureResourceGroups) {
    Write-Output "($azureResourceGroupCounter) $($azureResourceGroup.ResourceGroupName)"
    $azureResourceGroupCounter++;
}

$azureResourceGroupNumber = Read-Host 'Please choose ResourceGroups'
$resourceGroup = $azureResourceGroups[$azureResourceGroupNumber - 1].ResourceGroupName
Get-AzResource -ResourceGroupName $resourceGroup | Format-Table -Property ResourceGroupName, Name, Type, Tags
Get-AzResource -ResourceGroupName $resourceGroup | Select-Object -Property ResourceGroupName, Name, Type, Tags | Export-Csv filename.csv
[array]$Resource = Get-AzResource -ResourceGroupName $resourceGroup -Tag @{}

$response = Read-Host " Delete all resources without tags? (Y/N) "
Switch ($response) 
     { 
       Y {foreach ($res in $Resource) {
            Remove-AzResource -ResourceGroupName $resourceGroup -ResourceName $res.Name -ResourceType $res.Type -Force
          }
        } 
       N {Write-Host "Ok. See you later"} 
     } 
