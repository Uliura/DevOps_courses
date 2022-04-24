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
$SubscriptionId = $azureSubscriptions[$subscriptionNumber - 1].Id
$azureResourceGroups = Get-AzResourceGroup | Select-Object ResourceGroupName

$azureResourceGroupCounter = 1
foreach ($azureResourceGroup in $azureResourceGroups) {
    Write-Output "($azureResourceGroupCounter) $($azureResourceGroup.ResourceGroupName)"
    $azureResourceGroupCounter++;
}
$azureResourceGroupNumber = Read-Host 'Please choose ResourceGroups'
$resourceGroupName = $azureResourceGroups[$azureResourceGroupNumber - 1].ResourceGroupName 

[array]$VMArray = Get-AzVM -ResourceGroupName $resourceGroupName | Select-Object -Property Name, VmId, Location, Id

foreach ($VM in $VMArray){
  $ScheduledShutdownResourceId = "/subscriptions/$($SubscriptionId)/resourceGroups/$($resourceGroupName)/providers/Microsoft.DevTestLab/schedules/shutdown-computevm-$($VM.Name)"
  $VMShutdownInfo = Get-AzResource -ResourceId $ScheduledShutdownResourceId       
  $Properties = @{}
  $Properties.Add('status', 'Enabled')
  $Properties.Add('taskType', 'ComputeVmShutdownTask')
  $Properties.Add('dailyRecurrence', @{time=2000})
  $Properties.Add('timeZoneId', "E. Europe Standard Time")
  $Properties.Add('TargetResourceId', $VM.Id)
  
  if ($null -eq $VMShutdownInfo.properties.status -or "Disabled" -eq $VMShutdownInfo.properties.status) {
    New-AzResource -ResourceId $ScheduledShutdownResourceId -Location $VM.Location -Properties $Properties -Force
  }
}

Foreach ($VM in $VMArray) {
  Write-Output "$(Get-Date -format s) :: VM: $($VM.Name) :: $($resourceGroupName) :: $($VM.Id)"
  $ScheduledShutdownResourceId = "/subscriptions/$($SubscriptionId)/resourceGroups/$($resourceGroupName)/providers/Microsoft.DevTestLab/schedules/shutdown-computevm-$($VM.Name)"
  ## Write-Output "$ScheduledShutdownResourceId"
  $VMShutdownInfo = Get-AzResource -ResourceId $ScheduledShutdownResourceId
  Write-Output "$(Get-Date -format s) :: VM: $($VM.VMName) :: status: $($VMShutdownInfo.properties.status) ; taskType: $($VMShutdownInfo.properties.taskType) ; timeZoneId: $($VMShutdownInfo.properties.timeZoneId) ; dailyRecurrence: $($VMShutdownInfo.properties.dailyRecurrence) ;  "
}
