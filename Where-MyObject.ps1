function Where-MyObject {
    [CmdletBinding(DefaultParameterSetName = 'ScriptBlockSet', HelpUri = 'http://go.microsoft.com/fwlink/?LinkID=113423', RemotingCapability = 'None')]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [psobject]
        ${InputObject},

        [Switch]
        ${Not},

        [Parameter(ParameterSetName='ScriptBlockSet', Mandatory=$true, Position=0)]
        [scriptblock]
        ${FilterScript},

        [Parameter(ParameterSetName = 'equal', Position = 0)]
        [Parameter(ParameterSetName = 'equal (case-sensitive)', Position = 0)]
        [Parameter(ParameterSetName = 'not equal', Position = 0)]
        [Parameter(ParameterSetName = 'not equal (case-sensitive)', Position = 0)]

        [Parameter(ParameterSetName = 'be greater than', Position = 0)]
        [Parameter(ParameterSetName = 'be greater than (case-sensitive)', Position = 0)]
        [Parameter(ParameterSetName = 'not be greater than', Position = 0)]
        [Parameter(ParameterSetName = 'not be greater than (case-sensitive)', Position = 0)]

        [Parameter(ParameterSetName = 'be less than', Position = 0)]
        [Parameter(ParameterSetName = 'be less than (case-sensitive)', Position = 0)]
        [Parameter(ParameterSetName = 'not be less than', Position = 0)]
        [Parameter(ParameterSetName = 'not be less than (case-sensitive)', Position = 0)]

        [Parameter(ParameterSetName = 'be like', Position = 0)]
        [Parameter(ParameterSetName = 'be like (case-sensitive)', Position = 0)]
        [Parameter(ParameterSetName = 'not be like', Position = 0)]
        [Parameter(ParameterSetName = 'not be like (case-sensitive)', Position = 0)]

        [Parameter(ParameterSetName = 'match', Position = 0)]
        [Parameter(ParameterSetName = 'match (case-sensitive)', Position = 0)]
        [Parameter(ParameterSetName = 'not match', Position = 0)]
        [Parameter(ParameterSetName = 'not match (case-sensitive)', Position = 0)]

        [Parameter(ParameterSetName = 'contain', Position = 0)]
        [Parameter(ParameterSetName = 'contain (case-sensitive)', Position = 0)]
        [Parameter(ParameterSetName = 'not contain', Position = 0)]
        [Parameter(ParameterSetName = 'not contain (case-sensitive)', Position = 0)]

        [Parameter(ParameterSetName = 'be in', Position = 0)]
        [Parameter(ParameterSetName = 'be in (case-sensitive)', Position = 0)]
        [Parameter(ParameterSetName = 'not be in', Position = 0)]
        [Parameter(ParameterSetName = 'not be in (case-sensitive)', Position = 0)]

        [Parameter(ParameterSetName = 'be a', Position = 0)]
        [Parameter(ParameterSetName = 'not be a', Position = 0)]
        [AllowEmptyString()][AllowNull()]
        [System.Object]
        ${Property},

        [Parameter(ParameterSetName = 'equal', Position = 1)]
        [Parameter(ParameterSetName = 'equal (case-sensitive)', Position = 1)]
        [Parameter(ParameterSetName = 'not equal', Position = 1)]
        [Parameter(ParameterSetName = 'not equal (case-sensitive)', Position = 1)]

        [Parameter(ParameterSetName = 'be greater than', Position = 1)]
        [Parameter(ParameterSetName = 'be greater than (case-sensitive)', Position = 1)]
        [Parameter(ParameterSetName = 'not be greater than', Position = 1)]
        [Parameter(ParameterSetName = 'not be greater than (case-sensitive)', Position = 1)]

        [Parameter(ParameterSetName = 'be less than', Position = 1)]
        [Parameter(ParameterSetName = 'be less than (case-sensitive)', Position = 1)]
        [Parameter(ParameterSetName = 'not be less than', Position = 1)]
        [Parameter(ParameterSetName = 'not be less than (case-sensitive)', Position = 1)]

        [Parameter(ParameterSetName = 'be like', Position = 1)]
        [Parameter(ParameterSetName = 'be like (case-sensitive)', Position = 1)]
        [Parameter(ParameterSetName = 'not be like', Position = 1)]
        [Parameter(ParameterSetName = 'not be like (case-sensitive)', Position = 1)]

        [Parameter(ParameterSetName = 'match', Position = 1)]
        [Parameter(ParameterSetName = 'match (case-sensitive)', Position = 1)]
        [Parameter(ParameterSetName = 'not match', Position = 1)]
        [Parameter(ParameterSetName = 'not match (case-sensitive)', Position = 1)]

        [Parameter(ParameterSetName = 'contain', Position = 1)]
        [Parameter(ParameterSetName = 'contain (case-sensitive)', Position = 1)]
        [Parameter(ParameterSetName = 'not contain', Position = 1)]
        [Parameter(ParameterSetName = 'not contain (case-sensitive)', Position = 1)]

        [Parameter(ParameterSetName = 'be in', Position = 1)]
        [Parameter(ParameterSetName = 'be in (case-sensitive)', Position = 1)]
        [Parameter(ParameterSetName = 'not be in', Position = 1)]
        [Parameter(ParameterSetName = 'not be in (case-sensitive)', Position = 1)]

        [Parameter(ParameterSetName = 'be a', Position = 1)]
        [Parameter(ParameterSetName = 'not be a', Position = 1)]
        [AllowEmptyString()][AllowNull()]
        [System.Object]
        ${Value},

        [Parameter(ParameterSetName='equal', Mandatory=$true)]
        [Alias('IEQ')]
        [Alias('BeEqualTo')]
        [Alias('Equal')]
        [switch]
        ${EQ},

        [Parameter(ParameterSetName='equal (case-sensitive)', Mandatory=$true)]
        [Alias('BeExactlyEqualTo')]
        [Alias('EqualExactly')]
        [switch]
        ${CEQ},

        [Parameter(ParameterSetName='not equal', Mandatory=$true)]
        [Alias('INE')]
        [Alias('NotBeEqualTo')]
        [Alias('NotEqual')]
        [switch]
        ${NE},

        [Parameter(ParameterSetName='not equal (case-sensitive)', Mandatory=$true)]
        [Alias('NotBeExactlyEqualTo')]
        [Alias('NotExactlyEqual')]
        [switch]
        ${CNE},

        [Parameter(ParameterSetName='be greater than', Mandatory=$true)]
        [Alias('IGT')]
        [Alias('BeGreaterThan')]
        [switch]
        ${GT},

        [Parameter(ParameterSetName='be greater than (case-sensitive)', Mandatory=$true)]
        [switch]
        [Alias('BeExactlyGreaterThan')]
        ${CGT},

        [Parameter(ParameterSetName='be less than', Mandatory=$true)]
        [Alias('ILT')]
        [Alias('BeLessThan')]
        [switch]
        ${LT},

        [Parameter(ParameterSetName='be less than (case-sensitive)', Mandatory=$true)]
        [Alias('BeExactlyLessThan')]
        [switch]
        ${CLT},

        [Parameter(ParameterSetName='not be less than', Mandatory=$true)]
        [Alias('NotBeLessThan')]
        [Alias('IGE')]
        [switch]
        ${GE},

        [Parameter(ParameterSetName='not be less than (case-sensitive)', Mandatory=$true)]
        [Alias('NotBeExactlyLessThan')]
        [switch]
        ${CGE},

        [Parameter(ParameterSetName='not be greater than', Mandatory=$true)]
        [Alias('ILE')]
        [Alias('NotBeGreaterThan')]
        [switch]
        ${LE},

        [Parameter(ParameterSetName='not be greater than (case-sensitive)', Mandatory=$true)]
        [Alias('NotBeExactlyGreaterThan')]
        [switch]
        ${CLE},

        [Parameter(ParameterSetName='be like', Mandatory=$true)]
        [Alias('ILike')]
        [Alias('BeLike')]
        [switch]
        ${Like},

        [Parameter(ParameterSetName='be like (case-sensitive)', Mandatory=$true)]
        [Alias('BeExactlyLike')]
        [switch]
        ${CLike},

        [Parameter(ParameterSetName='not be like', Mandatory=$true)]
        [Alias('NotBeLike')]
        [Alias('INotLike')]
        [switch]
        ${NotLike},

        [Parameter(ParameterSetName='not be like (case-sensitive)', Mandatory=$true)]
        [Alias('NotBeExactlyLike')]
        [switch]
        ${CNotLike},

        [Parameter(ParameterSetName='match', Mandatory=$true)]
        [Alias('IMatch')]
        [switch]
        ${Match},

        [Parameter(ParameterSetName='match (case-sensitive)', Mandatory=$true)]
        [Alias('MatchExactly')]
        [switch]
        ${CMatch},

        [Parameter(ParameterSetName='not match', Mandatory=$true)]
        [Alias('INotMatch')]
        [switch]
        ${NotMatch},

        [Parameter(ParameterSetName='not match (case-sensitive)', Mandatory=$true)]
        [Alias('NotMatchExactly')]
        [switch]
        ${CNotMatch},

        [Parameter(ParameterSetName='contain', Mandatory=$true)]
        [Alias('IContains')]
        [switch]
        ${Contains},

        [Parameter(ParameterSetName='contain (case-sensitive)', Mandatory=$true)]
        [Alias('ContainsExactly')]
        [Alias('ContainExactly')]
        [switch]
        ${CContains},

        [Parameter(ParameterSetName='not contain', Mandatory=$true)]
        [Alias('INotContains')]
        [switch]
        ${NotContains},

        [Parameter(ParameterSetName='not contain (case-sensitive)', Mandatory=$true)]
        [Alias('NotContainsExactly')]
        [Alias('NotContainExactly')]
        [switch]
        ${CNotContains},

        [Parameter(ParameterSetName='be in', Mandatory=$true)]
        [Alias('IIn')]
        [Alias('BeIn')]
        [switch]
        ${In},

        [Parameter(ParameterSetName='be in (case-sensitive)', Mandatory=$true)]
        [Alias('BeInExactly')]
        [switch]
        ${CIn},

        [Parameter(ParameterSetName='not be in', Mandatory=$true)]
        [Alias('INotIn')]
        [Alias('NotBeIn')]
        [switch]
        ${NotIn},

        [Parameter(ParameterSetName='not be in (case-sensitive)', Mandatory=$true)]
        [Alias('NotBeInExactly')]
        [switch]
        ${CNotIn},

        [Parameter(ParameterSetName='be a', Mandatory=$true)]
        [Alias('BeA')]
        [switch]
        ${Is},

        [Parameter(ParameterSetName='not be a', Mandatory=$true)]
        [Alias('NotBeA')]
        [switch]
        ${IsNot}
    )
    begin {
        $PropertyValue = $False
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            if ($PSCmdlet.ParameterSetName -ne "ScriptBlockSet" -and -not $PSBoundParameters.ContainsKey('Value')) {
                $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('ForEach-Object', [System.Management.Automation.CommandTypes]::Cmdlet)
                $Parameters = @{ } + $PSBoundParameters

                $PropertyValue = $True
                $Parameters['Value'] = $Parameters['Property']
                $Parameters['Property'] = "Value"

                if ($Parameters.ContainsKey('InputObject')) {
                    $Parameters['InputObject'] = @{ "Value" = $InputObject }
                } else {
                    $Parameters['InputObject'] = { @{ "Value" = $_ } }
                }
                $scriptCmd = {& $wrappedCmd { if ($null -ne ($_ | Where-Object @Parameters)) { $_ } }}
            } else {
                $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Where-Object', [System.Management.Automation.CommandTypes]::Cmdlet)
                $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#
    .ForwardHelpTargetName Where-Object
    .ForwardHelpCategory Cmdlet
    #>
}