function CVC-Config
{
    [CmdletBinding()]
    Param(
            [Parameter()]
            [ValidateSet("Functions","Documents")]
            [System.String]
            $configType
    )

    Write-Verbose "CVC-Config`tFind config file"
    $configPath = Join-path (Split-Path $PSScriptRoot -Parent) "\xml\CvcConfig.xml"

    Write-Verbose "CVC-Config`tConfig File: $($configPath)"    
    [xml]$config = Get-Content $configPath

    Write-Verbose "CVC-Config`tCreate hash-table for functions & documents"
    $props = @{}

    switch ($configType)
    {
        'Functions'
        {
            Write-Verbose "CVC-Config`tEnumerate functions and add to hash-table"
            foreach ( $n in $config.config.Function.GetEnumerator())
            {
                $props.Add($n.Name,$n.Location)
            }
        }
        'Documents'
        {
            Write-Verbose "CVC-Config`tCreate-hash-table for documents"
            $props = @{}
            foreach ( $m in $config.config.Document.GetEnumerator())
            {
                $props.Add($m.Name,$m.Location)
            }
        }
    }

    Write-Output $props
}
