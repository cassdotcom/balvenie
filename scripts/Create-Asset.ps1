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

$dataTable = Data {

    ConvertFrom-StringData @'
    ProjectsRoot=C:\\Users\\ac00418\\Documents\\CVC\\projects\\
    ProjectRegister=C:\\Users\\ac00418\\Documents\\CVC\\xml\\ProjectRegister.xml
    AssetLibrary=C:\\Users\\ac00418\\Documents\\CVC\\xml\\AssetLibrary.xml
'@
}

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
    DynamicParam{
        # Configuration data
        $config = CVC-Config -configType Documents
        
        # New-DynamicParam -name Project -ValidateSet $(([xml](gc $dataTable.ProjectRegister)).GetElementsByTagName("Project").Name) -Mandatory
        New-DynamicParam -name Project -ValidateSet $(([xml](gc $config.ProjectRegister)).GetElementsByTagName("Project").Name) -Mandatory

    }

    Begin{
        # Configuration data
        $config = CVC-Config -configType Documents

        # Dynamic parameters
        foreach ($param in $PSBoundParameters.Keys)
        {
            if (-not (Get-Variable -Name $param -Scope 0 -ErrorAction SilentlyContinue))
            {
                New-Variable -Name $param -Value $PSBoundParameters.$param
            }
        }

        # Flag when duplicate hash found
        $dupeFlag = $false
    }

    Process{  

        # REPORTING
        Write-Verbose "Create-Asset`tSTART FUNCTION @ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Write-Verbose "Create-Asset`t------------------------------------------"
        Write-Verbose "Create-Asset`tCreate new asset in library"
        Write-Verbose "Create-Asset`tOpen asset library"



        # Open asset library
        [xml]$assetLibrary = Get-Content $config.AssetLibrary



        <#
            STOP DUPLICATES
        #>
        # Check if asset exists
        Write-Verbose "Create-Asset`tCheck for pre-existing asset..."

        # Get hash of asset
        Write-Verbose "Create-Asset`tGet hash of asset"
        $assetHash = (Get-FileHash $assetLocation -Algorithm SHA256).Hash

        foreach ( $n in $assetLibrary.AssetLibrary.Asset.GetEnumerator() ) {
            if ( $n.Hash -match $assetHash ) {
                Write-Warning "Create-Asset`tAsset is already in repository"
                Write-Warning "Create-Asset`tAsset is part of project $($n.Project)"
                Write-Warning "Create-Asset`tUse PUSH to update function and PULL to source function"
                $dupeFlag = $true
                break
            }
        }

        # Get name of asset
        Write-Verbose "Create-Asset`tCheck names"
        foreach ( $n in $assetLibrary.AssetLibrary.Asset.GetEnumerator() ) {
            if ( $n.Name -match $assetName ) {
                Write-Warning "Create-Asset`tAsset name already exists"
                Write-Warning "Create-Asset`tAsset is part of project $($n.Project)"
                Write-Warning "Create-Asset`tUse PUSH to update function and PULL to source function"
                $dupeFlag = $true
                break
            }
        }

        # Check location of asset
        Write-Verbose "Create-Asset`tCheck location"
        foreach ( $n in $assetLibrary.AssetLibrary.Asset.GetEnumerator() ) {
            $strComparer = $n.Location.compareto($assetLocation)
            if ( $strComparer -eq 0 ) {
                Write-Warning "Create-Asset`tAsset location already exists"
                Write-Warning "Create-Asset`tAsset is part of project $($n.Project)"
                Write-Warning "Create-Asset`tUse PUSH to update function and PULL to source function"
                $dupeFlag = $true
                break
            }
        }




        <#
            CREATE REPOSITORY NODE
        #>

        if ( $dupeFlag -eq $false ) {

            # PROJECT REGISTER
            # Get project from register
            Write-Verbose "Create-Asset`tOpen project register"
            [xml]$projectRegister = gc $config.ProjectRegister
            $assetProj = ( $projectRegister.ProjectRegister.Project | where { $_.Name -match $Project } )

            # Get project code
            Write-Verbose "Create-Asset`tGet project code"
            $projCode = $assetProj.PID.Substring(0,4)
            # Create Asset ID
            $assetID = Create-AssetID -projCode $projCode
            

            # Get project root and create file name
            $newAssetLocation = $assetProj.Location + "\" + $assetID + ".cvc"

            # Copy asset to folder
            Write-Verbose "Create-Asset`tCopy asset to project folder"
            $cvcCopy =  Copy-Item -Path $assetLocation -Destination $newAssetLocation
            
            # Update asset count
            Write-Verbose "Create-Asset`tUpdate asset count"
            [System.Int32]$newAssetCount = ($assetProj.AssetCount)
            $assetProj.AssetCount = [System.String]($newAssetCount + 1)


            


            # Create new node in xml
            $newAsset = $assetLibrary.AssetLibrary.AppendChild($assetLibrary.CreateElement("Asset"))

            # Name
            Write-Verbose "Create-Asset`t`t... Name ..."
            $newName = $newAsset.AppendChild($assetLibrary.CreateElement("Name"))
            $newNameText = $newName.AppendChild($assetLibrary.CreateTextNode($assetName))
            # Author
            Write-Verbose "Create-Asset`t`t... Author ..."
            $newAuthor = $newAsset.AppendChild($assetLibrary.CreateElement("Author"))
            $newAuthorText = $newAuthor.AppendChild($assetLibrary.CreateTextNode($assetAuthor))
            # Creation date
            Write-Verbose "Create-Asset`t`t... Creation date ..."
            $assetDate = Get-Date -Format yyyyMMdd
            $newDate = $newAsset.AppendChild($assetLibrary.CreateElement("CreationDate"))
            $newDateText = $newDate.AppendChild($assetLibrary.CreateTextNode($assetDate))
            # Creation Time
            Write-Verbose "Create-Asset`t`t... Creation time ..."
            $assetTime = Get-Date -Format HHmmss
            $newTime = $newAsset.AppendChild($assetLibrary.CreateElement("CreationTime"))
            $newTimeText = $newTime.AppendChild($assetLibrary.CreateTextNode($assetTime))
            # Comment
            Write-Verbose "Create-Asset`t`t... Comment ..."
            $newComment = $newAsset.AppendChild($assetLibrary.CreateElement("Comment"))
            $newCommentText = $newComment.AppendChild($assetLibrary.CreateTextNode($assetComment))
            # Description
            Write-Verbose "Create-Asset`t`t... Description ..."
            $newDescription = $newAsset.AppendChild($assetLibrary.CreateElement("Description"))
            $newDescriptionText = $newDescription.AppendChild($assetLibrary.CreateTextNode($assetDescription))
            # Project
            Write-Verbose "Create-Asset`t`t... Project ..."
            $newProject = $newAsset.AppendChild($assetLibrary.CreateElement("Project"))
            $newProjectText = $newProject.AppendChild($assetLibrary.CreateTextNode($Project))
            # Location
            Write-Verbose "Create-Asset`t`t... Location ..."
            $newLocation = $newAsset.AppendChild($assetLibrary.CreateElement("Location"))
            $newLocationText = $newLocation.AppendChild($assetLibrary.CreateTextNode($assetLocation))
            # AID
            Write-Verbose "Create-Asset`t`t... AID ..."
            $newAID = $newAsset.AppendChild($assetLibrary.CreateElement("AID"))
            $newPIDText = $newAID.AppendChild($assetLibrary.CreateTextNode($assetID))
            # Asset hash
            Write-Verbose "Create-Asset`t`t... Hash ..."
            $assetHash = Get-FileHash -Path $assetLocation
            $newHash = $newAsset.AppendChild($assetLibrary.CreateElement("Hash"))
            $newHashText = $newHash.AppendChild($assetLibrary.CreateTextNode($assetHash.Hash))


            <#
                SAVE XML FILES
            #>

            # Save register
            Write-Verbose "Create-Asset`tSave Register"
            $projectRegister.Save($config.ProjectRegister)

            # Save register
            Write-Verbose "Create-Asset`tSave Library"
            $assetLibrary.Save($config.assetLibrary)
        }
    }

    End{
        Write-Verbose "Create-Asset`t------------------------------------------"
        Write-Verbose "Create-Asset`tEND OF FUNCTION @ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }

}#endFunction Create-Asset
