## I need some additional PSReadLine configuration as well
if($Host.Name -eq "ConsoleHost" -and !$NOCONSOLE) {
    Set-PSReadlineKeyHandler Ctrl+Shift+C CaptureScreen
    Set-PSReadlineKeyHandler Ctrl+Shift+R ForwardSearchHistory
    Set-PSReadlineKeyHandler Ctrl+R ReverseSearchHistory

    Set-PSReadlineKeyHandler Ctrl+UpArrow HistorySearchBackward
    Set-PSReadlineKeyHandler Ctrl+DownArrow HistorySearchForward

    Set-PSReadlineKeyHandler Ctrl+M SetMark
    Set-PSReadlineKeyHandler Ctrl+Shift+M ExchangePointAndMark

    Set-PSReadlineKeyHandler Ctrl+K KillLine
    Set-PSReadlineKeyHandler Ctrl+I Yank
    Trace-Message "PSReadLine fixed"
} else {
    Remove-Module PSReadLine -ErrorAction SilentlyContinue
    Trace-Message "PSReadLine skipped!"
}

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

    if($Host.Name -ne "ConsoleHost") {
       Write-Warning "This script assumes ConsoleHost and PSReadLine."
       if($Host.Name -eq "Windows PowerShell ISE Host") {
            $Host.PrivateData.ErrorForegroundColor    = "DarkRed"
            $Host.PrivateData.WarningForegroundColor  = "Gold"
            $Host.PrivateData.DebugForegroundColor    = "Green"
            $Host.PrivateData.VerboseForegroundColor  = "Cyan"
            if($PSProcessElevated) {
                $Host.UI.RawUI.BackgroundColor = "DarkGray"
            }
        }

       if(!$Force) { return }
    }

    Set-PSReadlineOption -ContinuationPromptForegroundColor DarkGray -ContinuationPromptBackgroundColor $BackgroundColor -ContinuationPrompt "``  "
    Set-PSReadlineOption -EmphasisForegroundColor White -EmphasisBackgroundColor Gray

    Set-PSReadlineOption -TokenKind Keyword   -ForegroundColor "${Dark}Yellow" -BackgroundColor $BackgroundColor
    Set-PSReadlineOption -TokenKind String    -ForegroundColor "DarkGreen" -BackgroundColor $BackgroundColor
    Set-PSReadlineOption -TokenKind Operator  -ForegroundColor "DarkRed" -BackgroundColor $BackgroundColor
    Set-PSReadlineOption -TokenKind Number    -ForegroundColor "Red" -BackgroundColor $BackgroundColor
    Set-PSReadlineOption -TokenKind Variable  -ForegroundColor "${Dark}Magenta" -BackgroundColor $BackgroundColor
    Set-PSReadlineOption -TokenKind Command   -ForegroundColor "${Dark}Gray" -BackgroundColor $BackgroundColor
    Set-PSReadlineOption -TokenKind Parameter -ForegroundColor "DarkCyan" -BackgroundColor $BackgroundColor
    Set-PSReadlineOption -TokenKind Type      -ForegroundColor "Blue" -BackgroundColor $BackgroundColor

    Set-PSReadlineOption -TokenKind Member    -ForegroundColor "Cyan" -BackgroundColor $BackgroundColor
    Set-PSReadlineOption -TokenKind None      -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    Set-PSReadlineOption -TokenKind Comment   -ForegroundColor "DarkGray" -BackgroundColor $BackgroundColor

    [PowerLine.Prompt]$global:PowerLinePrompt = 1,
        (
            $null, # No left-aligned content on this line
            @(
                @{ text = { New-PowerLineBlock (Get-Elapsed) -ErrorBackgroundColor DarkRed -ErrorForegroundColor White -ForegroundColor Black -BackgroundColor DarkGray } }
                @{ bg = "Gray";     fg = "Black"; text = { Get-Date -f "T" } }
            )
        ),  @(
                @{ bg = "Blue";     fg = "White"; text = { $MyInvocation.HistoryId } }
                @{ bg = "Cyan";     fg = "White"; text = { [PowerLine.Prompt]::Gear * $NestedPromptLevel } }
                @{ bg = "Cyan";     fg = "White"; text = { if($pushd = (Get-Location -Stack).count) { "$([char]187)" + $pushd } } }
                @{ bg = "DarkBlue"; fg = "White"; text = { $pwd.Drive.Name } }
                @{ bg = "DarkBlue"; fg = "White"; text = { Split-Path $pwd -leaf } }
            )

    Set-PowerLinePrompt -CurrentDirectory -PowerlineFont:(!$SafeCharacters) -Title { "PowerShell - {0} ({1})" -f (Convert-Path $pwd),  $pwd.Provider.Name }


    if(Get-Module PSGit) {
        $PowerLinePrompt.Lines[-1].Columns[-1].Blocks.Add( @{ text = { Get-GitStatusPowerline } } )

        Set-GitPromptSettings -SeparatorText '' -BeforeText '' -BeforeChangesText '' -AfterChangesText '' -AfterNoChangesText '' `
                              -BranchText "§ " -BranchForeground White -BranchBackground Cyan `
                              -BehindByText '▼' -BehindByForeground White -BehindByBackground DarkCyan `
                              -AheadByText '▲' -AheadByForeground White -AheadByBackground DarkCyan `
                              -StagedChangesForeground White -StagedChangesBackground DarkBlue `
                              -UnStagedChangesForeground White -UnStagedChangesBackground Blue
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
    [string[]]$folders = Get-ChildItem $ProfileDir\Tool[s], $ProfileDir\Utilitie[s], $ProfileDir\Scripts\*, $ProfileDir\Script[s] -ad | % FullName

    ## Developer tools stuff ...
    ## I need InstallUtil, MSBuild, and TF (TFS) and they're all in the .Net RuntimeDirectory OR Visual Studio*\Common7\IDE
    if("System.Runtime.InteropServices.RuntimeEnvironment" -as [type]) {
        $folders += [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
    }

    ## MSBuild is now in 'C:\Program Files (x86)\MSBuild\{version}'
    $folders += Set-AliasToFirst -Alias "msbuild" -Path 'C:\Program Files (x86)\MSBuild\*\Bin\MsBuild.exe' -Description "Visual Studio's MsBuild" -Force -Passthru
    $folders += Set-AliasToFirst -Alias "merge" -Path "C:\Program*Files*\Perforce\p4merge.exe","C:\Program*Files*\DevTools\Perforce\p4merge.exe" -Description "Perforce" -Force -Passthru
    $folders += Set-AliasToFirst -Alias "tf" -Path "C:\Program*Files*\*Visual?Studio*\Common7\IDE\TF.exe", "C:\Program*Files*\DevTools\*Visual?Studio*\Common7\IDE\TF.exe" -Description "Visual Studio" -Force -Passthru
    # Side note: I search "D:" here, but you could put any USB drive letter ...
    $folders += Set-AliasToFirst -Alias "Python","Python2","py2" -Path "C:\Python2*\python.exe", "D:\Python2*\python.exe" -Description "Python 2.x" -Force -Passthru
    $folders += Set-AliasToFirst -Alias "Python3","py3" -Path "${Env:ProgramFiles}\Python3*\python.exe", "C:\Python3*\python.exe", "C:\Anaconda3\python.exe", "D:\Python3*\python.exe" -Description "Python 3.x" -Force -Passthru
    Set-AliasToFirst -Alias "iis","iisexpress" -Path 'C:\Progra*\IIS*\IISExpress.exe' -Description "Personal Profile Alias"
    Trace-Message "Development aliases set"

    $ENV:PATH = Select-UniquePath $folders ${Env:Path}
    Trace-Message "Env:PATH Updated"
}

$QuoteDir = Join-Path (Split-Path $ProfileDir -parent) "Quotes"
if(!(Test-Path $QuoteDir)) {
    $QuoteDir = Join-Path $PSScriptRoot Quotes
}

# Only export $QuoteDir if it refers to a folder that actually exists
Set-Variable QuoteDir (Resolve-Path $QuoteDir) -Scope Global -Option AllScope -Description "Personal Quotes Path Source"

function Get-Quote {
    param(
        $Path = "${QuoteDir}\attributed quotes.txt",
        [int]$Count=1
    )
    if(!(Test-Path $Path) ) {
        $Path = Join-Path ${QuoteDir} $Path
        if(!(Test-Path $Path) ) {
            $Path = $Path + ".txt"
        }
    }
    Get-Content $Path | Where-Object { $_ } | Get-Random -Count $Count
}

Set-Alias gq Get-Quote
Trace-Message "Random Quotes Loaded"

# Run these functions once
Update-ToolPath
Set-HostColor

## Get a random quote, and print it in yellow :D
if( Test-Path "${QuoteDir}\attributed quotes.txt" ) {
    Get-Quote | Write-Host -Foreground Yellow
}

Export-ModuleMember -Function * -Alias *