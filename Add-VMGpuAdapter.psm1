#region help
<#
.SYNOPSIS
Assign and configure a GPU for the use with a Hyper-V VM
.DESCRIPTION
.PARAMETER
.EXAMPLE
.INPUTS
.OUTPUTS
.NOTES
Implementation is based on 'Assign-VMGPUPartitionAdapter' extracted from https://github.com/jamesstringerparsec/Easy-GPU-PV/blob/main/CopyFilesToVM.ps1
.LINK
#>
#endregion

function Add-VMGpuAdapter {
    param(
        [string]$VMName,
        [string]$GPUName = "AUTO",
        [decimal]$GPUResourceAllocationPercentage = 100
    )

    $PartitionableGPUList = Get-VMHostPartitionableGpu
    if ($GPUName -eq "AUTO") {
        $DevicePathName = $PartitionableGPUList.Name[0]
        Add-VMGpuPartitionAdapter -VMName $VMName -InstancePath $DevicePathName
    }
    else {
        $DeviceID = ((Get-WmiObject Win32_PNPSignedDriver | where { ($_.Devicename -eq "$GPUName") }).hardwareid).split('\')[1]
        $DevicePathName = ($PartitionableGPUList | Where-Object name -like "*$DeviceID*").Name
        Add-VMGpuPartitionAdapter -VMName $VMName -InstancePath $DevicePathName
    }

    [float]$devider = [math]::round($(100 / $GPUResourceAllocationPercentage), 2)

    Set-VMGpuPartitionAdapter -VMName $VMName -MinPartitionVRAM ([math]::round($(1000000000 / $devider))) -MaxPartitionVRAM ([math]::round($(1000000000 / $devider))) -OptimalPartitionVRAM ([math]::round($(1000000000 / $devider)))
    Set-VMGPUPartitionAdapter -VMName $VMName -MinPartitionEncode ([math]::round($(18446744073709551615 / $devider))) -MaxPartitionEncode ([math]::round($(18446744073709551615 / $devider))) -OptimalPartitionEncode ([math]::round($(18446744073709551615 / $devider)))
    Set-VMGpuPartitionAdapter -VMName $VMName -MinPartitionDecode ([math]::round($(1000000000 / $devider))) -MaxPartitionDecode ([math]::round($(1000000000 / $devider))) -OptimalPartitionDecode ([math]::round($(1000000000 / $devider)))
    Set-VMGpuPartitionAdapter -VMName $VMName -MinPartitionCompute ([math]::round($(1000000000 / $devider))) -MaxPartitionCompute ([math]::round($(1000000000 / $devider))) -OptimalPartitionCompute ([math]::round($(1000000000 / $devider)))
}
