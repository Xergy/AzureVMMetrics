#if not logged in to Azure, start login
if ($Null -eq (Get-AzureRmContext).Account) {
    Login-AzureRmAccount -Environment ( (Get-AzureRmEnvironment).Name | Out-GridView -Title "Select AzureRmEnvironment" -OutputMode Single )
}

#Set Verbose
$VerbosePreference = "continue"

#region Build Config File
$sub = @()
$RGSelection = @()
$VMs = @()
$RGVMs = @()

#Clean up old jobs
Get-Job | Remove-Job

$subs = Get-AzureRmSubscription | Out-GridView -OutputMode Multiple -Title "Select Subscriptions" 

$Scriptblock = {
Param(
    [Object]$MetricsVM
)
    $MetricDefs = Get-AzureRmMetricDefinition -ResourceId $MetricsVM.Id -WarningAction SilentlyContinue | Where-Object {
        $_.Name.Value -eq "Percentage CPU" -or
        $_.Name.Value -eq "Network In"  -or
        $_.Name.Value -eq "Network Out" -or
        $_.Name.Value -eq "Disk Read Bytes" -or
        $_.Name.Value -eq "Disk Write Bytes" -or
        $_.Name.Value -eq "Disk Read Operations/Sec" -or
        $_.Name.Value -eq "Disk Write Operations/Sec"
    }

    #Write-Verbose "All MetricDefs for $($MetricsVM.Name)"
    #$MetricDefs.Name.Value

    Foreach ($MetricDef in $MetricDefs ) {
        
        Write-Verbose $MetricDef.Name.Value
        $PrimaryAggregationType = $MetricDef.PrimaryAggregationType
        Write-Verbose $PrimaryAggregationType

        $MetricsVM | Add-Member -MemberType NoteProperty -Name $MetricDef.Name.Value -Value (Get-AzureRmMetric -ResourceId $MetricsVM.Id -TimeGrain 00:01:00 -MetricName $MetricDef.Name.Value -WarningAction SilentlyContinue).Data[0].$PrimaryAggregationType            
        $MetricsVM | Add-Member -MemberType NoteProperty -Name SubscriptionID -Value $MetricsVM.Id.Split("/")[2] -Force        
    } 

    Return $MetricsVM
}


foreach ( $sub in $subs )
{
    Select-AzureRmSubscription -SubscriptionId $sub.Id 

    Write-Verbose "Look for Out-GridView PopUp!"
    $RGSelection = Get-AzureRmResourceGroup  | Out-GridView -Title "Select Resource Groups for $($sub.Name) $($sub.id)" -OutputMode Multiple

    ForEach ($RG in $RGSelection) {
        
        $RGVMs = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName

        ForEach ($VM in $RGVMs) {            

            $VM | Add-Member -MemberType NoteProperty -Name Status -Value ((Get-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Status).Statuses[1]).DisplayStatus -Force  
                        
            Write-Verbose "Starting Job for VM $($VM.Name)"
            Start-Job -Name $vm.Name -ScriptBlock $Scriptblock -ArgumentList $VM | Out-Null

        }

        Write-Verbose "Waiting for jobs to complete for $($RG.ResourceGroupName) in $($sub.Name) $($sub.id)"
        Get-Job | Wait-Job | Out-Null
        
        Write-Verbose "Cleaning up jobs for this RG"
        Get-Job | 
            ForEach-Object { 
                $VMs += $_ | Receive-Job -InformationAction SilentlyContinue ; $_ 
            } |
        Remove-Job

    }

}

$OutputFileProps = @(
    "Name"
    "ResourceGroupName"
    "SubscriptionID"
    "Location"
    "Status"
    "Percentage CPU"
    "Network In"
    "Network Out"
    "Disk Read Bytes"
    "Disk Write Bytes"
    "Disk Read Operations/Sec"
    "Disk Write Operations/Sec"
)

$NowStr = Get-Date -Format yyyy.MM.dd_HH.mm

$VMs | Select-Object -Property $OutputFileProps | Export-Csv -Path "C:\temp\$($NowStr)_AzureRmMetrics.csv" -NoTypeInformation 

$VMs | Select-Object -Property $OutputFileProps | Out-GridView
