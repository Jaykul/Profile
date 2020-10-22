class FileFormat {
    [string]$Color
    [char]$Icon

    FileFormat() {
        $this.Color = $global:Host.UI.RawUI.ForegroundColor
        $this.Icon = " "
    }

    FileFormat([string]$color) {
        $this.Color = $color
        $this.Icon = " "
    }

    FileFormat([string]$color, [char]$icon) {
        $this.Color = $color
        $this.Icon = $icon
    }
}

Add-MetadataConverter @{
    [FileFormat] = { "FileFormat '$($_.Color)' $($_.Icon)" }
    "FileFormat" = {
        param([string]$color, [char]$icon)
        [FileFormat]::new($color, $icon)
    }
}

$Configuration = Import-Configuration
if ($Configuration.FileColors) {
    $global:PSFileFormats = $Configuration.FileColors
}

if (Get-Command cond[a]) {
    function Import-Conda {
        [CmdletBinding()]
        param ()
        Add-PowerLineBlock { $Env:CONDA_PROMPT_MODIFIER } -Index ($Prompt.Count - 1)
        conda "shell.powershell" "hook" | Out-String | Invoke-Expression
    }
}

if ($Env:WT_SESSION) {
    Import-Module -FullyQualifiedName @{ ModuleName = "Theme.Terminal"; RequiredVersion = "0.1.0" } -Verbose:$false
}

if (Test-Elevation) {
    Import-Theme Lightly
} elseif($PSVersionTable.PSVersion.Major -le 5) {
    Import-Theme Legacy
} else {
    Import-Theme Darkly
}

function Update-PSReadLine {
    # Only configure PSReadLine if it's already running
    if (Get-Module PSReadline) {
        Set-PSReadlineKeyHandler Ctrl+Alt+c CaptureScreen
        Set-PSReadlineKeyHandler Ctrl+Shift+r ForwardSearchHistory
        Set-PSReadlineKeyHandler Ctrl+r ReverseSearchHistory

        Set-PSReadlineKeyHandler Ctrl+DownArrow HistorySearchForward
        Set-PSReadlineKeyHandler Ctrl+UpArrow HistorySearchBackward
        Set-PSReadLineKeyHandler Ctrl+Home BeginningOfHistory

        Set-PSReadlineKeyHandler Ctrl+m SetMark
        Set-PSReadlineKeyHandler Ctrl+Shift+m ExchangePointAndMark

        Set-PSReadlineKeyHandler Ctrl+K KillLine
        Set-PSReadlineKeyHandler Ctrl+I Yank

        Set-PSReadLineKeyHandler Ctrl+h BackwardDeleteWord
        Set-PSReadLineKeyHandler Ctrl+Enter AddLine
        Set-PSReadLineKeyHandler Ctrl+Shift+Enter AcceptAndGetNext
        Trace-Message "PSReadLine hotkeys fixed"

        $PSReadLineOption = @{
            AnsiEscapeTimeout             = 100
            BellStyle                     = "Audible"
            CompletionQueryItems          = 100
            ContinuationPrompt            = ">> "
            DingDuration                  = 50 #ms
            DingTone                      = 1221
            EditMode                      = "Windows"
            PromptText                    = "> "
            HistoryNoDuplicates           = $false
            HistorySaveStyle              = "SaveIncrementally"
            HistorySearchCaseSensitive    = $false
            HistorySearchCursorMovesToEnd = $false
            MaximumHistoryCount           = 1024
            MaximumKillRingCount          = 10
            ShowToolTips                  = $true
            WordDelimiters                = ";:,.[]{}()/\|^&*-=+"
        }
        $if ("PoshCode.Pansies.Entities" -as [Type]) {
            $PSReadLineOption.PromptText = [PoshCode.Pansies.Entities]::ExtendedCharacters.ColorSeparator
        }
    }
}
function Set-HostColor {
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


    if ($python = Set-AliasToFirst -Alias "Python", "py" -Path "C:\Program*Files*\Anaconda3*\python.exe", "C:\Program*Files*\*Visual?Studio*\Shared\Anaconda3*\python.exe" -Description "Python 3.x" -Force -Passthru) {
        $folders += $python
        $folders += @("Library\mingw-w64\bin", "Library\usr\bin", "Library\bin", "Scripts").ForEach({[io.path]::Combine($python, $_)})
        if ($python -match "conda") {
            $ENV:CONDA_PREFIX = $python
        }
    }

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
    Microsoft.PowerShell.Core\Remove-Module $ModuleName -Force
    Microsoft.PowerShell.Core\Import-Module $ModuleName -Force -Pass -Scope Global | Format-Table Name, Version, Path -Auto
}

function Get-Quote {
    [CmdletBinding()][Alias("gq")]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string]$Path = "${QuoteDir}\attributed quotes.txt",
        [int]$Count = 1
    )
    if (!(Test-Path $Path) ) {
        $Path = Join-Path ${QuoteDir} $Path
        if (!(Test-Path $Path) ) {
            $Path = $Path + ".txt"
        }
    }
    (Get-Content $Path) -ne '' | Get-Random -Count $Count
}

$QuoteDir = Join-Path (Split-Path $ProfileDir -parent) "Quotes"
if (!(Test-Path $QuoteDir)) {
    $QuoteDir = Join-Path $PSScriptRoot Quotes
}

# Only export $QuoteDir if it refers to a folder that actually exists
Set-Variable QuoteDir (Resolve-Path $QuoteDir) -Description "Personal Quotes Path Source"

if(!$ProfileDir -or !(Test-Path $ProfileDir)) {
    Set-Variable ProfileDir (Split-Path $Profile.CurrentUserAllHosts -Parent) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue
}


# If you log in with a Microsoft Identity, this will capture it
# Set-Variable LiveID (
#     [Security.Principal.WindowsIdentity]::GetCurrent().Groups.Where{
#         $_.Value -match "^S-1-11-96"
#     }.ForEach{$_.Translate([Security.Principal.NTAccount])}.Value
# ) -Option ReadOnly -ErrorAction SilentlyContinue


# Run these functions once
if (Test-Path "${QuoteDir}\attributed quotes.txt") {
    ## Get a random quote, and print it in yellow :D
    Get-Quote | Write-Host -Foreground "xt214"
}
Update-ToolPath
Update-PSReadLine
# In order for our File Format colors and History timing to take prescedence over the built-in ones, PREPEND the path:
Update-FormatData -PrependPath (Join-Path $PSScriptRoot 'Formats.ps1xml')

Export-ModuleMember -Function * -Alias * -Variable QuoteDir