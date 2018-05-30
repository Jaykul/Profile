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
Write-Warning "ProfileDir $ProfileDir"

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
# SIG # Begin signature block
# MIIXzgYJKoZIhvcNAQcCoIIXvzCCF7sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMmMWsV353Hu9+uiUYn/1hYF/
# 9H+gghMBMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9v
# dCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEwMjIxMjAwMDBaMHIxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNp
# Z25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD407Mcfw4R
# r2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx6nadBS63j/qSQ8Cl+YnUNxnXtqrw
# nIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEjlpB3gvmhhCNmElQzUHSxKCa7JGnC
# wlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvOf+l8
# y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2DZDv5LVOpKnqagqrhPOsZ061xPeM
# 0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6f
# pjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1Ud
# DwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGsw
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcw
# AoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Um9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDov
# L2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBP
# BgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93
# d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5eyoK
# o6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8w
# DQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+
# C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6ljlriXiSBThCk7j9xjmMOE0ut119E
# efM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR
# 4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/PQMtARKUT8OZkDCUIQjKyNookAv4v
# cn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwH
# gfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJmoecYpJpkUe8wggUwMIIEGKADAgEC
# AhAFmB+6PJIk/oqP7b4FPfHsMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25p
# bmcgQ0EwHhcNMTcwNjE0MDAwMDAwWhcNMTgwNjAxMTIwMDAwWjBtMQswCQYDVQQG
# EwJVUzERMA8GA1UECBMITmV3IFlvcmsxFzAVBgNVBAcTDldlc3QgSGVucmlldHRh
# MRgwFgYDVQQKEw9Kb2VsIEguIEJlbm5ldHQxGDAWBgNVBAMTD0pvZWwgSC4gQmVu
# bmV0dDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANALmLHevB7LvTmI
# p2oVErnz915fP1JUKoC+/5BRWUtAGooxg95jxX8+qT1yc02ZnkK7u1UyM0Mfs3b8
# MzhSqe5OkkQeT2RHrGe52+0/0ZWD68pvUBZoMQxrAnWJETjFO6IoXPKmoXN3zzpF
# +5s/UIbNGI5mdiN4v4F93Yaajzu2ymsJsXK6NgRh/AUbUzUlefpOas+o06wT0vqp
# LniGWw26321zJo//2QEo5PBrJvDDDIBBN6Xn5A2ww6v6fH2KGk2qf4vpr58rhDIH
# fLOHLg9s35effaktygUMQBCFmxOAbPLKWId8n5+O7zbMfKw3qxqCp2QeXhjkIh9v
# ETIX9pECAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZl
# dQ5YMB0GA1UdDgQWBBQ8xh3xoTXbMfJUSyFBfPsrxoD8XzAOBgNVHQ8BAf8EBAMC
# B4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDov
# L2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGG
# L2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3Js
# MEwGA1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8v
# d3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYw
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcw
# AoZCaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3Vy
# ZWRJRENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEL
# BQADggEBAGvlfIiin9JAyL16oeCNApnAWLfZpUBob4D+XLzdRJXidPq/pvNkE9Rg
# pRZFaWs30f2WPhWeqCpSCahoHzFsD5S9mOzsGTXsT+EdjAS0yEe1t9LfMvEC/pI3
# aBQJeJ/DdgpTMUEUJSvddc0P0NbDJ6TJC/niEMOJ8XvsfF75J4YVJ10yVNahbAuU
# MrRrRLe30pW74MRv1s7SKxwPmLhcsMQuK0mWGERtGYMwDHwW0ZdRHKNDGHRsl0Wh
# DS1P8+JRpE3eNFPcO17yiOfKDnVh+/1AOg7QopD6R6+P9rErorebsvW680s4WTlr
# hDcMsTOX0js2KFF6uT4nSojS4GNlSxExggQ3MIIEMwIBATCBhjByMQswCQYDVQQG
# EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
# cnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBT
# aWduaW5nIENBAhAFmB+6PJIk/oqP7b4FPfHsMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQKT0ZY
# 1lzrjfSfc46jC25yLurDkDANBgkqhkiG9w0BAQEFAASCAQDG+K2W2HudEGnsNLg3
# FY+pudevn/Q1g6J/0sid7QvQ4RpLytwqUVrqS1dBEEwQLRkt8Uosjpn+rcKCiMKi
# 03jjp8lcupdRgiVGq67R2seqOQ+8S9pbj+lEwORcTgMlGbtF3Ct4Vsoe2tjhV1qZ
# zsqMCnD32huEt/z1j/01tUVUI/Lini4IpDm/46n9UshEtkQY2tvQixd0z61XClYD
# zQ/UdUvRpcy+dGblrCazotMbZInWxYUSvzYId5eSHukQ8rwMzj1rJNdq2pYBqTPW
# kop0qBh2593rGJzUuZ3MD5Pukr11ryZZASms4vGhShbyaqheHr1rF5rvu3SB6OvW
# IB3foYICCzCCAgcGCSqGSIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UEBhMC
# VVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1h
# bnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81bgTY
# apgbGlAwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJ
# KoZIhvcNAQkFMQ8XDTE4MDUzMDA0Mjc1NFowIwYJKoZIhvcNAQkEMRYEFLz1Yc+4
# 35nUggmM6kqF0rvN7/p8MA0GCSqGSIb3DQEBAQUABIIBAJcVqdHrUQyXTMNaaN5T
# I8JowzK5znHGGrV+jK/dKu6G29BgA8Q1yMNaV+vE5ZXyOOHdX8uy7gqD7r/7yjDM
# FzJL40RPXR5uozuJQeUsoJOAFpuQttoprW+/ymvFV8LR63rjHJsgcrFWLEx2r7fz
# sXP+xmykTcN0frhPYRvZFR/2/CxlUt7KU28nAPeRtJykG81SvkbAZlZSWuHeE5fn
# /AsyKjqz817jqJ1CgW2H6x6dQg1OwTiCNBdqXerlnLRG9iocBRU+7cLjqw12Fipz
# K3yyMM9+7S47fjZlAZo3lVYmSarmKtFqAXyK7tmlMFEhrrSaJm0SFHspjcAFi9C1
# 36I=
# SIG # End signature block
