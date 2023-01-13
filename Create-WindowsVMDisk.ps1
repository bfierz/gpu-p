Param (
    [string]$SourcePath = '$PSSCriptRoot\Win11_22H2_EnglishInternational_x64v1.iso',
    # Index of the Windows Edition, 6 refers to Windows Pro
    [int]$Edition = 6,
    [string]$VHDPath = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\Disk.vhdx",
    [string]$VHDFormat = "VHDX",
    [string]$DiskLayout = "UEFI",
    [int64]$DiskSizeBytes = 40GB,
    [string]$GpuName = "AUTO",
    [string]$UnattendPath = "$PSScriptRoot\Media\unattend.xml"
)

#Requires -RunAsAdministrator

Import-Module $PSSCriptRoot\Convert-WindowsImage.psm1
Import-Module $PSScriptRoot\Add-VMGpuPartitionAdapterfiles.psm1

$OnCustomizeImage = {
    param($windowsDrive, $hklmHive)

    Add-VMGpuPartitionAdapterFiles -GPUName $GpuName -DriveLetter $windowsDrive

    # Registry tuning to disable AdWare (https://community.spiceworks.com/topic/2339916-windows-11-deployment-without-bloatware)
    New-Item -Path "HKLM:\$($hklmHive)\Software\Policies\Microsoft\Windows" -Name "CloudContent" -Force
    New-ItemProperty -Path "HKLM:\$($hklmHive)\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value "1" -PropertyType DWORD -Force
}

Convert-WindowsImage -SourcePath $SourcePath -Edition $Edition -VHDPath $VHDPath -VHDFormat $VHDFormat -DiskLayout $DiskLayout -SizeBytes $DiskSizeBytes -UnattendPath $UnattendPath -OnCustomizeImage $OnCustomizeImage
