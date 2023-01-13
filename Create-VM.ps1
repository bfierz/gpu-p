Param(
    # Name of the virtual machine
    [string] $VmName = "New Virtual Machine",
    # Folder to place the virtual machine
    [string] $VmPath = "C:\Users\Public\Documents\Hyper-V",
    # Path to the disk to use for the virtual machine
    [string] $VmDisk = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\NewVirtualMachineDisk.vhdx",
    # GPU name to load into the virtual machine (AUTO only works on Windows 11)
    [string] $VmGpu = "AUTO",
    # Size of the GPU partition in %
    [int] $VmGpuParition = 50,
    # Hyper-V network switch to connect to the virtual machine
    [string] $VmSwitch = "Default Switch"
)

#Requires -RunAsAdministrator

Import-Module $PSSCriptRoot\Add-VMGpuAdapter.psm1

# Create new VM; GPU-P requires generation 2 VM
New-VM -Name $VmName -Generation 2 -Path $VmPath

# Connect VM to local network
Connect-VMNetworkAdapter -VMName $VmName -SwitchName $VmSwitch

# Setup Windows 11 minimum requirements
Set-VM -Name $VmName -ProcessorCount 4
Set-VM -Name $VmName -MemoryStartupBytes 4096MB
Set-VMKeyProtector -VMName $VmName -NewLocalKeyProtector
Enable-VMTPM -VMName $VmName

# Only use as much RAM was required
Set-VM -Name $VmName -DynamicMemory

# Create a VM disk using the supplied vhdx
Add-VMHardDiskDrive -VMName $VmName -Path $VmDisk

# GPU-P does not support snapshots
Set-VM -Name $VmName -CheckpointType Disabled

# Prepare memory settings for GPU-P
Set-VM -GuestControlledCacheTypes $true -VMName $VmName
Set-VM -LowMemoryMappedIoSpace 1Gb -VMName $VmName
Set-VM -HighMemoryMappedIoSpace 32Gb -VMName $VmName

# Create a GPU partition to the VM
Add-VMGpuAdapter -VMName $VmName -GPUName $VmGpu -GPUResourceAllocationPercentage $VmGpuParition
