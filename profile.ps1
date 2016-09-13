trap { Write-Warning ($_.ScriptStackTrace | Out-String) }
# This timer is used by Trace-Message, I want to start it immediately
$TraceVerboseTimer = New-Object System.Diagnostics.Stopwatch
$TraceVerboseTimer.Start()

## Set the profile directory first, so we can refer to it from now on.
Set-Variable ProfileDir (Split-Path $MyInvocation.MyCommand.Path -Parent) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue

# Ensure that PSHome\Modules is there so we can load the default modules
$Env:PSModulePath += ";$PSHome\Modules"
# These will get loaded automatically, but it's faster to load them explicitly all at once
Import-Module Microsoft.PowerShell.Management,
              Microsoft.PowerShell.Security,
              Microsoft.PowerShell.Utility,
              Environment,
              Configuration,
              PSGit,
              PowerLine,
              Profile,
              DefaultParameter -Verbose:$false

# For now, CORE edition is always verbose, because I can't test for KeyState
if("Core" -eq $PSVersionTable.PSEdition) {
    $VerbosePreference = "Continue"
} else {
    # Check SHIFT state ASAP at startup so I can use that to control verbosity :)
    Add-Type -Assembly PresentationCore, WindowsBase
    try {
        if([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -OR
           [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)) {
            $VerbosePreference = "Continue"
        }
    } catch {}
}

# First call to Trace-Message, pass in our TraceTimer that I created at the top to make sure we time EVERYTHING.
# This has to happen after the verbose check, obviously
Trace-Message "Modules Imported" -Stopwatch $TraceVerboseTimer

Set-Variable LiveID (
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups |
        Where Value -match "^S-1-11-96" |
        ForEach Translate([System.Security.Principal.NTAccount]) |
        ForEach Value) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue

# I prefer that my sessions start in my profile directory
if($ProfileDir -ne (Get-Location)) { Set-Location $ProfileDir }

## Add my Projects folder to the module path
$Env:PSModulePath = Select-UniquePath "$ProfileDir\Modules" (Get-SpecialFolder *Modules -Value) ${Env:PSModulePath} "${Home}\Projects\Modules"
Trace-Message "Env:PSModulePath Updated"

## And a couple of functions that can't be saved as script files for whatever reason
function Reset-Module ($ModuleName) { rmo $ModuleName; ipmo $ModuleName -force -pass | ft Name, Version, Path -Auto }

## The qq shortcut for quick quotes
function qq {param([Parameter(ValueFromRemainingArguments=$true)][string[]]$q)$q}

# I have a hard time remembering to use ZLocation. This helped...
Set-Alias cd Set-ZLocation -Option AllScope

Trace-Message "Profile Finished!" -KillTimer
Remove-Variable TraceVerboseTimer

## Relax the code signing restriction so we can actually get work done
try { Set-ExecutionPolicy RemoteSigned Process } catch [PlatformNotSupportedException] {}

$VerbosePreference = "SilentlyContinue"