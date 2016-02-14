<#
    .SYNOPSIS
        Asset creation function
    
    .DESCRIPTION
        Function to create a new asset to be added to Project Asset Library
    .NOTES
        Credit to http://jrich523.wordpress.com/2013/05/30/powershell-simple-way-to-add-dynamic-parameters-to-advanced-function/
            Added logic to make option set optional
            Added logic to add RuntimeDefinedParameter to existing DPDictionary
            Added a little comment based help
        Credit to BM for alias and type parameters and their handling
    .PARAMETER Name
        Name of asset
    .PARAMETER Author
        Asset creator
    .PARAMETER Comment
        Information about the asset being created
    .PARAMETER Description
        Asset description
    .PARAMETER Location
        Asset location
    .PARAMETER Project
        Dynamic parameter generated from the Project Register
    .EXAMPLE
    # This example illustrates the use of New-DynamicParam to create a single dynamic parameter
    .EXAMPLE
    # I found many cases where I needed to add more than one dynamic parameter
        Function Test-DynPar{
            
    .FUNCTIONALITY
        PowerShell Language
#>

function Create-Asset
{
    [CmdletBinding()]
    Param(
        # Project name
        [Parameter(Mandatory=$true)]
        [System.String]
        $assetName,

        # Author
        [Parameter(Mandatory=$true)]
        [System.String]
        $assetAuthor,
                
        # Comment
        [Parameter(Mandatory=$false)]
        [System.String]
        $assetComment,

        # Description
        [Parameter(Mandatory=$true)]
        [System.String]
        $assetDescription,

        # Location
        [Parameter(Mandatory=$true)]
        [System.String]
        $assetLocation
    )


    Begin
    {

        # REPORTING
        # ======================================================================================
        Write-Verbose "Create-Asset`tSTART CREATE-ASSET @ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Write-Verbose "Create-Asset`t------------------------------------------"
        Write-Verbose "Create-Asset`tCreate new asset"
        # ======================================================================================
        
        # Configuration data
        $config = CVC-Config -configType Documents

        # Flag when duplicate found
        $dupeFlag = $false
    }

    Process
    {
        # FIND DUPLICATES
        # ======================================================================================
        Write-Verbose "Create-Asset`tCheck for existing asset..."
        Write-Verbose "Create-Asset`tGet hash of asset"
        $assetHash = (Get-FileHash -Path $assetLocation -Algorithm SHA256).Hash

        # Open asset library
        [xml]$assetLibrary = Get-Content $config.AssetLibrary

        # Compare against existing hashes
        if ( $assetLibrary.AssetLibrary.Asset | where { $_.Rev.hash -match $assetHash } ) {
            $dupeFlag = $true
            Write-Warning "Create-Asset`tAsset hash is already in repository"
            Write-Warning "Create-Asset`tUse PUSH to update function and PULL to source function"
            break
        }
        # ======================================================================================
        

        if ( !$dupeFlag ) {

        
            # CREATE ENTRY IN REGISTER
            # ======================================================================================
            # New asset ID
            Write-Verbose "Create-Asset`tNew ID...."
            $assetAID = Create-AssetID
            Write-Verbose "Create-Asset`t.... $($assetAID)"

            
            Write-Verbose "Create-Asset`tWrite to asset register"
            CVC-WriteToAssetRegister -file $config.AssetRegister

            <#
            # Open register
            [xml]$assetRegister = Get-Content $config.AssetRegister

            # New node
            $newAsset = $assetRegister.AssetRegister.AppendChild($assetRegister.CreateElement("Asset"))
            # Node name
            $newName = $newAsset.AppendChild($assetRegister.CreateElement("Name"))
            $newNameText = $newName.AppendChild($assetRegister.CreateTextNode($assetName))
            # Node AID
            $newAID = $newAsset.AppendChild($assetRegister.CreateElement("AID"))
            $newAIDText = $newAID.AppendChild($assetRegister.CreateTextNode($assetAID))
            # Save xml
            $assetRegister.Save($config.AssetRegister)
            #>
            # ======================================================================================


            


            # COPY ASSET TO REPO
            # ======================================================================================
            Write-Verbose "Create-Asset`tCopy asset to repository .... "
            $assetNewLocation = "C:\Users\ac00418\Documents\CVC\repo\" + $assetAID + "-00.revc"
            $assetCopy = Copy-Item -Path $assetLocation -Destination $assetNewLocation
            Write-Verbose "Create-Asset`t.... $($assetNewLocation)"
            # ======================================================================================





            # CREATE ENTRY IN LIBRARY
            # ======================================================================================
            Write-Verbose "Create-Asset`tWrite to hash library"
            CVC-WriteToAssetLibrary -file $config.AssetLibrary -assetHash $assetHash -assetAID $assetAID

            <#
            [xml]$assetLibrary = Get-Content $config.AssetLibrary

            # New node
            $newAsset = $assetLibrary.AssetLibrary.AppendChild($assetLibrary.CreateElement("Asset"))
            # Node AID
            $newAID = $newAsset.AppendChild($AssetLibrary.CreateElement("AID"))
            $newAIDText = $newAID.AppendChild($AssetLibrary.CreateTextNode($assetAID))
            # Node Rev
            $newRevision = $newAsset.AppendChild($assetLibrary.CreateElement("Rev"))
            $newRev = $newRevision.AppendChild($assetLibrary.CreateElement("rev"))
            $newRevText = $newRev.AppendChild($assetLibrary.CreateTextNode("00"))
            # Node Hash
            $newHash = $newRev.AppendChild($assetLibrary.CreateElement("hash"))
            $newHashText = $newHash.AppendChild($assetLibrary.CreateTextNode($assetHash))
            # Save xml
            $assetLibrary.Save($config.AssetLibrary)
            #>
            # ======================================================================================


        
            # CREATE CONTROL FILE
            # ======================================================================================
            # New file
            Write-Verbose "Create-Asset`tCreate asset control file ...."
            $assetPath = "C:\Users\ac00418\Documents\CVC\repo\" + $assetAID + ".cvc"
            $newAssetItem = New-Item -Path $assetPath -ItemType File
            Write-Verbose "Create-Asset`t.... $($assetPath)"

            CVC-WriteToAssetControl -xmlFile $assetPath -assetAuthor $assetAuthor -assetHash $assetHash -assetLocation $assetLocation -assetComment $assetComment

            <#
            # Begin xml
            $XMLWriter = New-Object System.Xml.XmlTextWriter($assetPath,$null)
            $XMLWriter.Formatting = "Indented"
            $XMLWriter.Indentation = "4"
            $XMLWriter.WriteStartDocument()
            $XMLWriter.WriteStartElement("AssetRevision")
            $XMLWriter.WriteStartElement("Rev")
            # Write revision number
            $XMLWriter.WriteAttributeString("rev","00")
            # Write author
            $XMLWriter.WriteElementString("Author",$assetAuthor)
            # Write creation date
            $assetDate = Get-Date -Format yyyyMMdd
            $XMLWriter.WriteElementString("CreationDate",$assetDate)
            # Write creation time
            $assetTime = Get-Date -Format HHmmss
            $XMLWriter.WriteElementString("CreationTime",$assetTime)
            # Write asset hash
            $XMLWriter.WriteElementString("Hash",$assetHash)
            # Write asset location
            $XMLWriter.WriteElementString("Location",$assetLocation)
            # Write asset comment
            $XMLWriter.WriteElementString("Comment",$assetComment)

            # Close 'Rev'
            $XMLWriter.WriteEndElement()
            # Close 'AssetRevision'
            $XMLWriter.WriteEndElement()
            # End document
            $XMLWriter.WriteEndDocument()
            $XMLWriter.Finalize
            $XMLWriter.Flush()
            # close xml
            $XMLWriter.Close()
            #>
            # ======================================================================================
        }
        
    }

    End{
        Write-Verbose "Create-Asset`t------------------------------------------"
        Write-Verbose "Create-Asset`tEND OF FUNCTION @ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }


}




function CVC-WriteToAssetRegister
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $file,
        
        [Parameter()]
        [System.String]
        $assetName,
        
        [Parameter()]
        [System.String]
        $assetAID
    )


    # Open register
    [xml]$xmlFile = Get-Content $file

    # New node
    $newAsset = $xmlFile.AssetRegister.AppendChild($xmlFile.CreateElement("Asset"))
    # Node name
    $newName = $newAsset.AppendChild($xmlFile.CreateElement("Name"))
    $newNameText = $newName.AppendChild($xmlFile.CreateTextNode($assetName))
    # Node AID
    $newAID = $newAsset.AppendChild($xmlFile.CreateElement("AID"))
    $newAIDText = $newAID.AppendChild($xmlFile.CreateTextNode($assetAID))
    # Save xml
    $xmlFile.Save($file)

}

function CVC-WriteToAssetLibrary
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $file,
        
        [Parameter()]
        [System.String]
        $assetHash,
        
        [Parameter()]
        [System.String]
        $assetAID
    )


    # Open library
    [xml]$xmlFile = Get-Content $file

    # New node
    $newAsset = $xmlFile.AssetLibrary.AppendChild($xmlFile.CreateElement("Asset"))
    # Node AID
    $newAID = $newAsset.AppendChild($xmlFile.CreateElement("AID"))
    $newAIDText = $newAID.AppendChild($xmlFile.CreateTextNode($assetAID))
    # Node Rev
    $newRevision = $newAsset.AppendChild($xmlFile.CreateElement("Rev"))
    $newRev = $newRevision.AppendChild($xmlFile.CreateElement("rev"))
    $newRevText = $newRev.AppendChild($xmlFile.CreateTextNode("00"))
    # Node Hash
    $newHash = $newRev.AppendChild($xmlFile.CreateElement("hash"))
    $newHashText = $newHash.AppendChild($xmlFile.CreateTextNode($assetHash))
    # Save xml
    $xmlFile.Save($file)


}

function CVC-WriteToAssetControl
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $xmlFile,
        
        [Parameter()]
        [System.String]
        $assetAuthor,
        
        [Parameter()]
        [System.String]
        $assetHash,
        
        [Parameter()]
        [System.String]
        $assetLocation,
        
        [Parameter()]
        [System.String]
        $assetComment
    )


    # Begin xml
    $XMLWriter = New-Object System.Xml.XmlTextWriter($xmlFile,$null)
    $XMLWriter.Formatting = "Indented"
    $XMLWriter.Indentation = "4"
    $XMLWriter.WriteStartDocument()
    $XMLWriter.WriteStartElement("AssetRevision")
    $XMLWriter.WriteStartElement("Rev")
    # Write revision number
    $XMLWriter.WriteAttributeString("rev","00")
    # Write author
    $XMLWriter.WriteElementString("Author",$assetAuthor)
    # Write creation date
    $assetDate = Get-Date -Format yyyyMMdd
    $XMLWriter.WriteElementString("CreationDate",$assetDate)
    # Write creation time
    $assetTime = Get-Date -Format HHmmss
    $XMLWriter.WriteElementString("CreationTime",$assetTime)
    # Write asset hash
    $XMLWriter.WriteElementString("Hash",$assetHash)
    # Write asset location
    $XMLWriter.WriteElementString("Location",$assetLocation)
    # Write asset comment
    $XMLWriter.WriteElementString("Comment",$assetComment)

    # Close 'Rev'
    $XMLWriter.WriteEndElement()
    # Close 'AssetRevision'
    $XMLWriter.WriteEndElement()
    # End document
    $XMLWriter.WriteEndDocument()
    $XMLWriter.Finalize
    $XMLWriter.Flush()
    # close xml
    $XMLWriter.Close()


}
