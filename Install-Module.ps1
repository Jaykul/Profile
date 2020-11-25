param(
    [Switch]$Force,

    [ValidateSet("CurrentUser","AllUser")]
    $Scope = "CurrentUser"
)
$ProfileDir = Split-Path $Profile.CurrentUserAllHosts
mkdir $ProfileDir\Modules -force | convert-path | Push-location

try {
    $ErrorActionPreference = "Stop"
    if(Test-Path Profile-master){
        Write-Error "The Profile-master folder already exists, install cannot continue."
    }
    if (Test-Path Profile){
        Write-Warning "The Profile module already exists, install will overwrite it and put the old one in Profile/old."
        Remove-Item Profile/old -Recurse -Force -ErrorAction SilentlyContinue
    }

    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest https://github.com/Jaykul/Profile/archive/master.zip -OutFile Profile-master.zip
    $ProgressPreference = "Continue"
    Expand-Archive Profile-master.zip .
    $null = mkdir Profile-master\old

    if (Test-Path Profile) {
        Move-Item Profile\* Profile-master\old
        Remove-Item Profile
    }

    Rename-Item Profile-master Profile
    Remove-Item Profile-master.zip

    if (!$Force -and (Test-Path $Profile.CurrentUserAllHosts)) {
        Write-Warning "Profile.ps1 already exists. Leaving existing profile in $($Profile.CurrentUserAllHosts)"
    } else {
        Set-Content $Profile.CurrentUserAllHosts @'
        $Actual = @(
            "$PSScriptRoot\Modules\Profile\profile.ps1"
            "A:\.pscloudshell\PowerShell\Modules\Profile\profile.ps1"
            "$Home\Projects\Modules\Profile\profile.ps1"
        ).Where({Test-Path $_}, 'First', 1)

        Write-Host "Actual Profile: $Actual" -ForegroundColor DarkYellow
        . $Actual
'@ -Encoding ascii
    }

    $Gallery = Get-PSRepository PSGallery
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    $RequiredModules = (Get-Module Profile -ListAvailable).RequiredModules.Name
    Write-Host "Installing Required Modules in Scope:$Scope $($RequiredModules -join ', ')"
    Find-Module $RequiredModules |
        Find-Module -AllowPrerelease |
        Install-Module -Scope:$Scope -RequiredVersion { $_.Version } -AllowPrerelease -AllowClobber

    Set-PSRepository -Name PSGallery -InstallationPolicy $Gallery.InstallationPolicy

} finally {
    Pop-Location
}