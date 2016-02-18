function Push-Asset
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.String]
        $pushName,

        [Parameter(Mandatory=$false)]
        [System.String]
        $pushLocation,

        [Parameter(Mandatory=$false)]
        [System.String]
        $pushComment,

        [Parameter(Mandatory=$true)]
        [System.String]
        $pushAuthor
    )

    Begin
    {

        # REPORTING
        # ======================================================================================
        Write-Verbose "Push-Asset`tSTART PUSH-ASSET @ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Write-Verbose "Push-Asset`t------------------------------------------"
        Write-Verbose "Push-Asset`tUpdate asset repo"
        # ======================================================================================

        $config = CVC-Config -configType Documents
        $dupeFlag = $false
    }

    Process
    {
        # ASSET REGISTER
        # ======================================================================================
        # Get asset from Register
        [xml]$assetRegister = Get-Content $config.AssetRegister

        # Match asset to name
        $currentAsset = $assetRegister.AssetRegister.Asset | where { $_.Name -match $pushName }

        # Pull AID and current revision number
        $currentAID = $currentAsset.AID
        $currentRev = $currentAsset.CurrentRev
        # ======================================================================================




        # CONTROL FILE LOCATION DETAILS
        # ======================================================================================
        $assetControlFile = $config.RepoRoot + "\" + $currentAID + ".cvc"
        [xml]$assetControl = Get-Content $assetControlFile
        # If no new location specified, pull from control file
        if ( !$pushLocation ) { 
            $pushLocation = ($assetControl.AssetRevision.Rev| where { $_.rev -match $currentRev }).Location
        }
        # ======================================================================================


        
        # CHECK AGAINST HASH VALUES
        # ======================================================================================
        [xml]$assetLibrary = Get-Content $config.AssetLibrary
        $pushHash = (Get-FileHash -Path $pushLocation -Algorithm SHA256).Hash
        # Check againstlibray hashes
        if ( $assetLibrary.AssetLibrary.Asset | where { $_.Rev.hash -match $pushHash } ) {
            $dupeFlag = $true
            Write-Warning "Push-Asset`tDuplicate hash detected in repository"
            Write-Warning "Push-Asset`tUse PULL to source function"
            break
        }
        # ======================================================================================




        if ( !$dupeFlag ) {

            # COPY TO REPO
            # ======================================================================================
            $newRev = [Int32]$currentRev + 1
            if ( $newRev -lt 10 ) {
                [System.String]$revFinal = "0" + $newRev
            } else {
                [System.String]$revFinal = $newRev
            }

            $pushNewLocation = $config.RepoRoot + "\" + $currentAID + "-" + $revFinal + ".revc"
            $pushCopy = Copy-Item -Path $pushLocation -Destination $pushNewLocation
            # ======================================================================================




            # UPDATE ASSET REGISTER
            # ======================================================================================
            # Asset register
            $currentAsset.CurrentRev = $revFinal
            $assetRegister.Save($config.AssetRegister)
            # ======================================================================================



            # UPDATE HASH LIBRARY
            # ======================================================================================
            # Find asset in library
            $libAsset = $assetLibrary.AssetLibrary.Asset | where { $_.AID -match $currentAID }
                # Create new revision
                $newRevision = $libAsset.AppendChild($assetLibrary.CreateElement("Rev"))
                    # Add revision number
                    $libRev = $newRevision.AppendChild($assetLibrary.CreateElement("rev"))
                    $libRevText = $libRev.AppendChild($assetLibrary.CreateTextNode($revFinal))
                    # Add revision hash
                    $libHash = $newRevision.AppendChild($assetLibrary.CreateElement("hash"))
                    $libHashText = $libHash.AppendChild($assetLibrary.CreateTextNode($pushHash))
                # Save file
                $assetLibrary.Save($config.AssetLibrary)
            # ======================================================================================



            # UPDATE CONTROL FILE
            # ======================================================================================
                $controlRev = $assetControl.AssetRevision.AppendChild($assetControl.CreateElement("Rev"))
                    # Revision number
                    $controlRevRev = $controlRev.AppendChild($assetControl.CreateElement("rev"))
                    $controlRevRevText = $controlRevRev.AppendChild($assetControl.CreateTextNode($revFinal))
                    # Author
                    $controlAuthor = $controlRev.AppendChild($assetControl.CreateElement("Author"))
                    $controlAuthorText = $controlAuthor.AppendChild($assetControl.CreateTextNode($pushAuthor))
                    # Creation date and time
                    $pushDate = Get-Date -Format yyyyMMdd
                    $pushtime = Get-Date -Format HHmmss
                    $controlDate = $controlRev.AppendChild($assetControl.CreateElement("CreationDate"))
                    $controlDateText = $controlDate.AppendChild($assetControl.CreateTextNode($pushDate))
                    $controlTime = $controlRev.AppendChild($assetControl.CreateElement("Creationtime"))
                    $controlTimeText = $controlTime.AppendChild($assetControl.CreateTextNode($pushtime))
                    # Hash
                    $controlHash = $controlRev.AppendChild($assetControl.CreateElement("Hash"))
                    $controlHashText = $controlHash.AppendChild($assetControl.CreateTextNode($pushHash))
                    # Location
                    $controlLocation = $controlRev.AppendChild($assetControl.CreateElement("Location"))
                    $controlLocationText = $controlLocation.AppendChild($assetControl.CreateTextNode($pushLocation))
                    # Comment
                    $controlComment = $controlRev.AppendChild($assetControl.CreateElement("Comment"))
                    $controlCommentText = $controlComment.AppendChild($assetControl.CreateTextNode($pushComment))
                $assetControl.Save($assetControlFile)

            # ======================================================================================


        }




    }

    End
    {
        # REPORTING
        # ======================================================================================
        Write-Verbose "Push-Asset`t------------------------------------------"
        Write-Verbose "Push-Asset`tEND OF FUNCTION @ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        # ======================================================================================

    }


}#endFunction Push-Asset
