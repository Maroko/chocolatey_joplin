﻿# Joplin Notes and To-Do
# 2018 foo.li systeme + software, afischer211
$ErrorActionPreference = 'Stop';
$toolsDir              = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version               = '2.13.15'
$packageSearch         = 'Joplin*'
$file           = Join-Path $toolsDir 'Joplin-Setup-' + $version + '.exe'
$installerType = 'exe'
$packageName   = 'joplin'
$url 			 = 'https://github.com/laurent22/joplin/releases/download/v' + $version + '/Joplin-Setup-' + $version + '.exe'
$checksum      = '8DB589A1D34F690A417E4ADB1AF51E36AFAE1B819217CBD3D14DC06B8304167F'
$checksumType  = 'sha256'

$packageArgs = @{
  packageName    = $packageName
  fileType       = $installerType
  softwareName   = $packageSearch
  silentArgs     = '/ALLUSERS=1 /S'
  validExitCodes = @(0)
  url           = $url
  url64bit      = $url
  checksum      = $checksum
  checksumType  = $checksumType
  checksum64    = $checksum
  checksumType64= $checksumType  
}

try {   
    $app = Get-ItemProperty -Path @('HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*') `
            -ErrorAction:SilentlyContinue | Where-Object { $_.DisplayName -like $packageSearch }
	
    if ($app -and ([version]$app.DisplayVersion -ge [version]$version)) {
        Write-Output $(
        'Joplin ' + $version + ' or greater is already installed. ' +
        'No need to download and install again. Otherwise uninstall first.'
        )
    } else {
        Install-ChocolateyPackage @packageArgs
    }           
} catch {
    throw $_.Exception
}
