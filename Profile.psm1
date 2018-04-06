function Set-HostColor {
    <#
        .Description
            Set more reasonable colors, because yellow is for warning, not verbose
    #>
    [CmdletBinding()]
    param(
        # Change the background color only if ConEmu didn't already do that.
        [Switch]$Light=$(Test-Elevation),

        # Don't use the special PowerLine characters
        [Switch]$SafeCharacters,

        # If set, run the script even when it's not the ConsoleHost
        [switch]$Force
    )

    ## In the PowerShell Console, we can only use console colors, so we have to pick them by name.
    if($Light) {
       $BackgroundColor = "White"
       $ForegroundColor = "Black"
       $PromptForegroundColor = "White"
       $Dark = "Dark"
    } else {
       $Dark = ""
       $BackgroundColor = "Black"
       $ForegroundColor = "White"
       $PromptForegroundColor = "White"
    }

    $Host.UI.RawUI.BackgroundColor = $BackgroundColor
    $Host.UI.RawUI.ForegroundColor = $ForegroundColor

    switch($Host.Name) {
        "ConsoleHost" {
            $Host.PrivateData.ErrorForegroundColor    = "DarkRed"
            $Host.PrivateData.ErrorBackgroundColor    = $BackgroundColor
            $Host.PrivateData.WarningForegroundColor  = "${Dark}Yellow"
            $Host.PrivateData.WarningBackgroundColor  = $BackgroundColor
            $Host.PrivateData.DebugForegroundColor    = "Green"
            $Host.PrivateData.DebugBackgroundColor    = $BackgroundColor
            $Host.PrivateData.VerboseForegroundColor  = "${Dark}Cyan"
            $Host.PrivateData.VerboseBackgroundColor  = $BackgroundColor
            $Host.PrivateData.ProgressForegroundColor = "DarkMagenta"
            $Host.PrivateData.ProgressBackgroundColor = "Gray"
        }
        "Windows PowerShell ISE Host" {
            $Host.PrivateData.ErrorForegroundColor    = "DarkRed"
            $Host.PrivateData.WarningForegroundColor  = "Gold"
            $Host.PrivateData.DebugForegroundColor    = "Green"
            $Host.PrivateData.VerboseForegroundColor  = "Cyan"
            if($PSProcessElevated) {
                $Host.UI.RawUI.BackgroundColor = "DarkGray"
            }
        }
        "Visual Studio Code Host" {

        }
        default {
            Write-Warning "Much of my profile assumes ConsoleHost + PSReadLine."
        }
    }

    # Func`2           AddToHistoryHandler
    # Action`1         CommandValidationHandler
    # String           PromptText = ((prompt) -split "`n" | select -last 1)
    # Int32            ExtraPromptLineCount = 2
    # ViModeStyle      ViModeIndicator
    # String           HistorySavePath

    $PSReadLineOption = @{
        AnsiEscapeTimeout             = 100
        BellStyle                     = "Audible"
        Colors                        = @{
            ContinuationPrompt = "DarkGray"
            Emphasis           = $ForegroundColor
            Error              = "Red"
            Selection          = "Red"
            Default            = $ForegroundColor
            Comment            = "DarkGray"
            Keyword            = "${Dark}Yellow"
            String             = "DarkGreen"
            Operator           = "DarkRed"
            Variable           = "${Dark}Magenta"
            Command            = "${Dark}Gray"
            Parameter          = "DarkCyan"
            Type               = "Blue"
            Number             = "Red"
            Member             = "Cyan"
        }
        CompletionQueryItems          = 100
        ContinuationPrompt            = ">> "
        DingDuration                  = 50 #ms
        DingTone                      = 1221
        EditMode                      = "Windows"
        HistoryNoDuplicates           = $false
        HistorySaveStyle              = "SaveIncrementally"
        HistorySearchCaseSensitive    = $false
        HistorySearchCursorMovesToEnd = $false
        MaximumHistoryCount           = 1024
        MaximumKillRingCount          = 10
        ShowToolTips                  = $true
        WordDelimiters                = ";:,.[]{}()/\|^&*-=+"
    }
    Set-PSReadlineOption @PSReadLineOption

    if(Get-Module PSGit -ErrorAction SilentlyContinue) {
        Set-GitPromptSettings -SeparatorText '' -BeforeText '' -BeforeChangesText '' -AfterChangesText '' -AfterNoChangesText '' `
                              -BranchText  "§ " -BranchForeground 'xt229'   -BranchBackground   $null `
                              -BehindByText '▼' -BehindByForeground 'xt183' -BehindByBackground $null `
                              -AheadByText  '▲' -AheadByForeground 'xt118'  -AheadByBackground  $null `
                              -StagedChangesForeground White -StagedChangesBackground $null `
                              -UnStagedChangesForeground Black -UnStagedChangesBackground $null
    }
}

function Update-ToolPath {
    #.Synopsis
    # Add useful things to the PATH which aren't normally there on Windows.
    #.Description
    # Add Tools, Utilities, or Scripts folders which are in your profile to your Env:PATH variable
    # Also adds the location of msbuild, merge, tf and python, as well as iisexpress
    # Is safe to run multiple times because it makes sure not to have duplicates.
    param()

    ## I add my "Scripts" directory and all of its direct subfolders to my PATH
    [string[]]$folders = Get-ChildItem $ProfileDir\Tool[s], $ProfileDir\Utilitie[s], $ProfileDir\Script[s]\*, $ProfileDir\Script[s] -ad | % FullName

    ## Developer tools stuff ...
    ## I need InstallUtil, MSBuild, and TF (TFS) and they're all in the .Net RuntimeDirectory OR Visual Studio*\Common7\IDE
    if("System.Runtime.InteropServices.RuntimeEnvironment" -as [type]) {
        $folders += [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
    }

    Set-AliasToFirst -Alias "iis","iisexpress" -Path 'C:\Progra*\IIS*\IISExpress.exe' -Description "IISExpress"
    $folders += Set-AliasToFirst -Alias "msbuild" -Path 'C:\Program*Files*\*Visual?Studio*\*\*\MsBuild\*\Bin\MsBuild.exe', 'C:\Program*Files*\MSBuild\*\Bin\MsBuild.exe' -Description "Visual Studio's MsBuild" -Force -Passthru
    $folders += Set-AliasToFirst -Alias "merge" -Path "C:\Program*Files*\Perforce\p4merge.exe" -Description "P4merge" -Force -Passthru
    $folders += Set-AliasToFirst -Alias "tf" -Path "C:\Program*Files*\*Visual?Studio*\*\*\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team?Explorer\TF.exe", "C:\Program*Files*\*Visual?Studio*\Common7\IDE\TF.exe" -Description "TFVC" -Force -Passthru
    $folders += Set-AliasToFirst -Alias "Python", "py" -Path "C:\Program*Files*\Anaconda3*\python.exe", "C:\Program*Files*\*Visual?Studio*\Shared\Anaconda3*\python.exe" -Description "Python 3.x" -Force -Passthru
    ## I don't use Python2 lately, but I can't quite convince myself I won't need it again
    #   $folders += Set-AliasToFirst -Alias "Python2", "py2" -Path "C:\Program*Files*\Anaconda3\python.exe", "C:\Python2*\python.exe" -Description "Python 2.x" -Force -Passthru
    Trace-Message "Development aliases set"

    $ENV:PATH = Select-UniquePath $folders ${Env:Path}
    Trace-Message "Env:PATH Updated"
}

function Reset-Module {
    <#
    .Synopsis
        Remove and re-import a module to force a full reload
    #>
    param($ModuleName)
    Microsoft.PowerShell.Core\Remove-Module $ModuleName
    Microsoft.PowerShell.Core\Import-Module $ModuleName -Force -Pass -Scope Global | Format-Table Name, Version, Path -Auto
}

if(!$ProfileDir -or !(Test-Path $ProfileDir)) {
    $ProfileDir = Split-Path $Profile.CurrentUserAllHosts
}

$QuoteDir = Join-Path (Split-Path $ProfileDir -parent) "Quotes"
if(!(Test-Path $QuoteDir)) {
    $QuoteDir = Join-Path $PSScriptRoot Quotes
}

# Only export $QuoteDir if it refers to a folder that actually exists
Set-Variable QuoteDir (Resolve-Path $QuoteDir) -Description "Personal Quotes Path Source"

function Get-Quote {
    [CmdletBinding()][Alias("gq")]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string]$Path = "${QuoteDir}\attributed quotes.txt",
        [int]$Count=1
    )
    if(!(Test-Path $Path) ) {
        $Path = Join-Path ${QuoteDir} $Path
        if(!(Test-Path $Path) ) {
            $Path = $Path + ".txt"
        }
    }
    Get-Content $Path | Where { $_ } | Get-Random -Count $Count
}

# Run these functions once
Set-HostColor
Update-ToolPath

Trace-Message "Random Quotes Loaded"

## Get a random quote, and print it in yellow :D
if( Test-Path "${QuoteDir}\attributed quotes.txt" ) {
    Get-Quote | Write-Host -Foreground "xt214"
}

# If you log in with a Windows Identity, this will capture it
Set-Variable LiveID (
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups |
        Where Value -match "^S-1-11-96" |
        ForEach Translate([System.Security.Principal.NTAccount]) |
        ForEach Value) -Option ReadOnly -ErrorAction SilentlyContinue

function Update-PSReadLine {
    Set-PSReadlineKeyHandler Ctrl+Shift+C CaptureScreen
    Set-PSReadlineKeyHandler Ctrl+Shift+R ForwardSearchHistory
    Set-PSReadlineKeyHandler Ctrl+R ReverseSearchHistory

    Set-PSReadlineKeyHandler Ctrl+DownArrow HistorySearchForward
    Set-PSReadlineKeyHandler Ctrl+UpArrow HistorySearchBackward
    Set-PSReadLineKeyHandler Ctrl+Enter AcceptAndGetNext
    Set-PSReadLineKeyHandler Ctrl+Home BeginningOfHistory

    Set-PSReadlineKeyHandler Ctrl+M SetMark
    Set-PSReadlineKeyHandler Ctrl+Shift+M ExchangePointAndMark

    Set-PSReadlineKeyHandler Ctrl+K KillLine
    Set-PSReadlineKeyHandler Ctrl+I Yank
    Trace-Message "PSReadLine hotkeys fixed"

    ## There were some problems with hosts using PSReadLine who shouldn't
    if ($Host.Name -ne "ConsoleHost") {
        Remove-Module PSReadLine -ErrorAction SilentlyContinue
        Trace-Message "PSReadLine unloaded!"
    }
}

# Only configure PSReadLine if it's already running
if (Get-Module PSReadline) {
    Update-PSReadLine
}

# Unfortunately, in order for our File Format colors and History timing to take prescedence, we need to PREPEND the path:
Update-FormatData -PrependPath (Join-Path $PSScriptRoot 'Formats.ps1xml')

Export-ModuleMember -Function * -Alias * -Variable LiveID, QuoteDir