trap { Write-Warning ($_.ScriptStackTrace | Out-String) }
# This timer is used by Trace-Message, I want to start it immediately
$TraceVerboseTimer = New-Object System.Diagnostics.Stopwatch
$TraceVerboseTimer.Start()
${;} = [System.IO.Path]::PathSeparator

# Ensure that PSHome\Modules is there so we can load the default modules
# Azure CloudShell doesn't have a Modules path in clouddrive yet.
$Env:PSModulePath += "$PSHome\Modules", "$Home\Projects\Modules", (Split-Path $PSScriptRoot) -join [System.IO.Path]::PathSeparator

# Azure CloudShell pwsh freaks out if you try to load these explicitly.
# # # # # # # # # # # Bleeping Computer # # # # # # # # # # # 
# # Note these normally get loaded automatically, but it's faster to load them explicitly up front
# Import-Module Microsoft.PowerShell.Management,
#               Microsoft.PowerShell.Security,
#               Microsoft.PowerShell.Utility -Verbose:$false

## Set the profile directory first, so we can refer to it from now on.
Set-Variable ProfileDir (Split-Path $Profile.CurrentUserAllHosts -Parent) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue

# Note these are dependencies of the Profile module, but it's faster to load them explicitly up front
Import-Module -FullyQualifiedName @{ ModuleName = "Environment";       ModuleVersion = "1.0.4" },
                                  @{ ModuleName = "Configuration";     ModuleVersion = "1.2.1" },
                                  @{ ModuleName = "Pansies";           ModuleVersion = "1.2.1" },
                                  @{ ModuleName = "PowerLine";         ModuleVersion = "3.0.5" },
                                  @{ ModuleName = "DefaultParameter";  ModuleVersion = "1.7.0" } -Verbose:$false

# If it's Windows PowerShell, we can turn on Verbose output if you're holding shift
if ("Desktop" -eq $PSVersionTable.PSEdition) {
    # Import-Module xColors
    # Check SHIFT state ASAP at startup so I can use that to control verbosity :)
    Add-Type -Assembly PresentationCore, WindowsBase
    try {
        if ([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -OR
            [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)) {
            $VerbosePreference = "Continue"
        }
    } catch {
        # If that didn't work ... oh well.
    }
}

Import-Module -FullyQualifiedName @{ ModuleName = "Profile";           ModuleVersion = "1.2.2" } -Verbose:$false

# First call to Trace-Message, pass in our TraceTimer that I created at the top to make sure we time EVERYTHING.
# This has to happen after the verbose check, obviously
Trace-Message "Modules Imported" -Stopwatch $TraceVerboseTimer

# I prefer that my sessions start in a predictable location, regardless of elevation, etc.
if($ProfileDir -ne (Get-Location)) { Set-Location $ProfileDir }

## Make sure that all the module folders are in the PSModulePath
$Env:PSModulePath = Select-UniquePath "$ProfileDir\Modules" (Get-SpecialFolder *Modules -Value) ${Env:PSModulePath} "${Home}\Projects\Modules"
Trace-Message "Env:PSModulePath Updated"

Trace-Message "Profile Finished!" -KillTimer
Remove-Variable TraceVerboseTimer

## Relax the code signing restriction so we can actually get work done
Set-ExecutionPolicy RemoteSigned Process
$VerbosePreference = "SilentlyContinue"