$VerbosePreference = "continue"

#Get-AzureRmMetricDefinition -ResourceId $Vm.Id | fl -Property Name

$Defs = Get-AzureRmMetricDefinition -ResourceId $Vm.Id

$Defs = Get-AzureRmMetricDefinition -ResourceId $Vm.Id 

$Defs | fl -Property Name

# CPU, Disk, Network

$VM = Get-AzureRmVm -Name Ariel -ResourceGroupName Prod-RG

(Get-AzureRmMetric -ResourceId $Vm.Id).Data -TimeGrain 00:01:00 -DetailedOutput

Get-AzureRmMetricDefinition -ResourceId $Vm.Id 

Get-AzureRmMetricDefinition -ResourceId $Vm.Id | fl -Property Name

(Get-AzureRmMetricDefinition -ResourceId $Vm.Id)[0].Name.Value

(Get-AzureRmMetricDefinition -ResourceId $Vm.Id)[0].PrimaryAggregationType

$MetricName = (Get-AzureRmMetricDefinition -ResourceId $Vm.Id).Name.Value

Get-AzureRmMetric -ResourceId $Vm.Id -TimeGrain 00:01:00 -DetailedOutput -MetricName "Percentage CPU"

(Get-AzureRmMetric -ResourceId $Vm.Id -TimeGrain 00:01:00 -DetailedOutput -MetricName "Per Disk Read Bytes/sec").Data

(Get-AzureRmMetric -ResourceId $Vm.Id -TimeGrain 00:01:00 -DetailedOutput -MetricName "Network In").Data[0]

$AggregationType = "Average"
(Get-AzureRmMetric -ResourceId $Vm.Id -TimeGrain 00:01:00 -DetailedOutput -MetricName "Network In" -AggregationType "Average").Data[0].$AggregationType

Get-AzureRmMetric -ResourceId $Vm.Id -DetailedOutput -

Get-AzureRmMetric -ResourceId $Vm.Id 

(Get-AzureRmMetric -ResourceId $Vm.Id).Data[0] | gm

(Get-AzureRmMetric -ResourceId $Vm.Id).Data[0] 


get-azurermdisk -ResourceGroupName Prod-RG | fl -Property Name,Id

Ariel_OsDisk_1_738b63cb462940fb9f35982fa7d994dd

$Disk = get-azurermdisk -ResourceGroupName Prod-RG -DiskName "Ariel_OsDisk_1_738b63cb462940fb9f35982fa7d994dd"

Get-AzureRmMetric -ResourceId $Disk.Id 

#Get all Resource Names

$MetricNames = @(
    "Percentage CPU"
    "Network In"
    "Network Out"
    "Disk Read Bytes"
    "Disk Write Bytes"
    "Disk Read Operations/Sec"
    "Disk Write Operations/Sec"
    #"Per Disk Read Bytes/sec"
    #"Per Disk Write Bytes/sec"
    #"Per Disk Read Operations/Sec"
    #"Per Disk Write Operations/Sec"
    #"Per Disk QD"
    #"OS Per Disk Read Bytes/sec"
    #"OS Per Disk Write Bytes/sec"
    #"OS Per Disk Read Operations/Sec"
    #"OS Per Disk Write Operations/Sec"
    #"OS Per Disk QD"
    #"Inbound Flows"
    #"Outbound Flows"
)


#Get Subs
#Loop on Subs
    #Get RGs

    #Loop on RGs
        #Get all VMs in RG
            #Loop on VM
            #Create VM Object with Name, RG, ID
                #Loop on Each metric Name 
                #Add members for each Metric

#End results with VM object with Metrics as properity Names and Values

$VMs = $null
$VMs = (Get-AzureRmVM)[0..5]

ForEach ($VM in $VMs) {

    <#
    $MetricDefs = Get-AzureRmMetricDefinition -ResourceId $VM.Id | Where-Object {
        $_.Name.Value -eq "Percentage CPU" -or
        $_.Name.Value -eq "Network In" -or
        $_.Name.Value -eq "Network Out" -or
        $_.Name.Value -eq "Disk Read Bytes" -or
        $_.Name.Value -eq "Disk Write Bytes" -or
        $_.Name.Value -eq "Disk Read Operations/Sec" -or
        $_.Name.Value -eq "Disk Write Operations/Sec"
    }
    #>

    $MetricDefs = Get-AzureRmMetricDefinition -ResourceId $VM.Id 

    $MetricDefs.Name.Value

    Foreach ($MetricDef in $MetricDefs ) {
        
        Write-Verbose $MetricDef.Name.Value
        $PrimaryAggregationType = $MetricDef.PrimaryAggregationType
        Write-Verbose $PrimaryAggregationType
        (Get-AzureRmMetric -ResourceId $Vm.Id -TimeGrain 00:01:00 -DetailedOutput -MetricName $MetricDef.Name.Value).Data[0].$PrimaryAggregationType

        $VM | Add-Member -MemberType NoteProperty -Name $MetricDef.Name.Value -Value (Get-AzureRmMetric -ResourceId $Vm.Id -TimeGrain 00:01:00 -DetailedOutput -MetricName $MetricDef.Name.Value).Data[0].$PrimaryAggregationType
        
        #Write-Host "$MetricName"
        #(Get-AzureRmMetric -ResourceId $Vm.Id -TimeGrain 00:01:00 -DetailedOutput -MetricName $MetricName).Data[0]

        #$VMMetricsAll += $MetricName

    } 

}



(Get-AzureRmMetric -ResourceId $Vm.Id -TimeGrain 00:01:00 -DetailedOutput -MetricName $MetricName).Data[0]

$VMs[2] | fl *

$VMs
cls


get-help Start-Job  -ShowWindow

$scriptblock = { "Hello World" }

get-job | Remove-Job

get-job | Receive-Job

Get-Job | Remove-Job

((Get-AzureRmVM -ResourceGroupName Prod-RG -Name Ariel -Status).Statuses[1]).DisplayStatus


#new stuff:

(Get-AzureRmMetricDefinition -ResourceId $VM.id).name 

Get-AzureRmMetric -ResourceId $VM.id -TimeGrain 00:01:00 -DetailedOutput -MetricName "per Disk Read Operations/Sec" 

$endTime = Get-Date
$startTime = $endTime.AddMinutes(-160)
$timeGrain = '00:01:00'
#$metricName = "OS Per Disk Read Operations/Sec","OS Per Disk Write Bytes/sec","OS Per Disk Read Operations/Sec","OS Per Disk Write Operations/Sec","Per Disk Read Operations/Sec","Per Disk Write Bytes/sec"
$metricName = "OS Per Disk Read Operations/Sec"
#$id = "/subscriptions/0ab6a744-42f5-4b9e-ab5c-1a187cf43dfd/resourceGroups/testdemo/providers/Microsoft.Compute/virtualMachines/DEMOtest"

$metricName = "OS Per Disk Write Operations/Sec"

$VM = get-azurermvm -ResourceGroupName F5-RG -Name F5Jumpbox
(Get-AzureRmMetric -ResourceId $VM.Id -TimeGrain $timeGrain -StartTime $startTime -EndTime $endTime -MetricNames $metricName) | select -ExpandProperty data

