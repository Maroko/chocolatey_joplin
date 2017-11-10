# Kopano Outlook Extension
# 2017 foo.li systeme + software
# https://www.gnu.org/licenses/gpl.txt

$packageName    = 'kopano-ol-extension-nightly'
$packageSearch  = 'Kopano OL Extension'
$installerType  = 'msi'
$silentArgs     = '/qb'
$version        = '1.6.246'
$intvers        = '1.6-246'
$url            = 'https://download.kopano.io/community/olextension:/KopanoOLExtension-' + $intvers + '-32bit.msi'
$url64          = 'https://download.kopano.io/community/olextension:/KopanoOLExtension-' + $intvers + '-64bit.msi'
$checksum       = '6F877FB2C693681F5E2002C5F9B365372A034C77'
$checksumType   = 'sha1'
$checksum64     = '1CA137E458ADEB7241F33CBD82E42E44925A109A'
$checksumType64 = $checksumType

try {   
    $app = Get-ItemProperty -Path @('HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*') `
            -ErrorAction:SilentlyContinue | Where-Object { $_.DisplayName -like $packageSearch }

    if ($app -and ([version]$app.DisplayVersion -ge [version]$version)) {
        Write-Host -ForegroundColor DarkYellow $(
        "Kopano OL Extension " + $version + " or greater is already installed. `n" +
        "No need to download and install again. Otherwise uninstall first."
        )
    } else {
        #check for outlook
        #https://www.reddit.com/r/PowerShell/comments/47lhdt/simple_script_to_check_if_outlook_is_installed/
        #if (Get-ItemProperty HKLM:\SOFTWARE\Classes\Outlook.Application -ErrorAction SilentlyContinue) {
        #    Write-Output "Outlook found"
        #} else {
        #    Write-Output "Outlook could not be found"
        #    throw $_.Exception
        #}
        if (get-wmiobject Win32_Product |where {$_.Name -like "*Outlook*" -and $_.Version -ge "15"}) {
            #works with non-retail...
            Write-Output "Outlook 2013 (or higher) seems to be present"
            Install-ChocolateyPackage $packageName $installerType $silentArgs $url $url64 `
                        -checksum $checksum -checksumType $checksumType `
                        -checksum64 $checksum64 -checksumType64 $checksumType64
        } else {
            #works with retail versions...
            $olkey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\OUTLOOK.EXE'
            $olpath = (Get-ItemProperty $olkey -ErrorAction SilentlyContinue).Path
            if ($olpath) {
                if (Test-Path $olpath) {
                    if ($olpath -like "*Office15*") { Write-Host -ForegroundColor DarkYellow "Outlook 2013 detected" }
                    if ($olpath -like "*Office16*") { Write-Host -ForegroundColor DarkYellow "Outlook 2016 detected" }
                    Write-Output "Outlook 2013 (or higher) seems to be present"
                    Install-ChocolateyPackage $packageName $installerType $silentArgs $url $url64 `
                            -checksum $checksum -checksumType $checksumType `
                            -checksum64 $checksum64 -checksumType64 $checksumType64
                } else {
                    Write-Output "unsupported (or no) Outlook Version detected"
                    throw $_.Exception
                }
           } else {
                Write-Output "unsupported (or no) Outlook Version detected"
                throw $_.Exception
           }
        }
    }
} catch {
    throw $_.Exception
}
