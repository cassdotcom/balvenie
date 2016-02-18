function Pull-Asset
{
     [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.String]
        $pullName,

        [Parameter(Mandatory=$false)]
        [System.String]
        $pullRevision
    )

     Begin
    {

        # REPORTING
        # ======================================================================================
        Write-Verbose "Pull-Asset`tSTART PULL-ASSET @ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Write-Verbose "Pull-Asset`t------------------------------------------"
        Write-Verbose "Pull-Asset`tUpdate asset repo"
        # ======================================================================================

        $config = CVC-Config -configType Documents
        $dupeFlag = $false
    }





    Process
    {
        # GET AID
        # ======================================================================================
        [xml]$assetRegister = Get-Content $config.AssetRegister

        # Match asset to name
        $currentAsset = $assetRegister.AssetRegister.Asset | where { $_.Name -match $pullName }

        # Pull AID and current revision number
        $currentAID = $currentAsset.AID

        if ( !$pullRevision ) {
            $currentRevision = $currentAsset.CurrentRev
        } else {
            $currentRevision = $pullRevision
        }



        
        # CONTROL FILE
        # ======================================================================================
        $assetControlFile = $config.RepoRoot + "\" + $currentAID + ".cvc"
        [xml]$assetControl = Get-Content $assetControlFile

        $pullAsset = $assetControl.AssetRevision.Rev | where { $_.rev -match $currentRevision }
        # ======================================================================================




        
        # ASSET INFO
        # ======================================================================================
        $pullFileExtension = [System.IO.Path]::GetExtension($pullAsset.Location)
        $pullFilePath = $config.PullRoot + "\" + $pullName + $pullFileExtension

        # Revision file
        $assetToPull = $config.RepoRoot + "\" + $currentAID + "-" + $currentRevision + ".revc"
        # Test!
        if ( ! ( Test-Path $assetToPull ) ) {
            Write-Warning "Pull-Asset`tAsset revision $($currentRevision) does not exist."
            $dupeFlag = $true
            break
        }
        # ======================================================================================



        
        # EXPORT ASSET
        # ======================================================================================
        if ( !$dupeFlag ) {
            $assetCopy = Copy-Item -Path $assetToPull -Destination $pullFilePath -Force

            Write-Verbose "Pull-Asset`tAsset exported to Pull directory"
        }
        # ======================================================================================



    }




    End
    {
        Write-Verbose "Pull-Asset`t------------------------------------------"
        Write-Verbose "Pull-Asset`tEND OF FUNCTION @ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    }


}
