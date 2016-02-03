<#
    Version Control
    Create a new project object
#>

$dataTable = Data {

    ConvertFrom-StringData @'
    ProjectsRoot=C:\\Users\\ac00418\\Documents\\CVC\\projects\\
    ProjectRegister=C:\\Users\\ac00418\\Documents\\CVC\\xml\\ProjectRegister.xml
'@
}

function Create-Project
{
    [CmdletBinding()]
    Param(
        # Project name
        [Parameter(Mandatory=$true)]
        [System.String]
        $projName,

        # Author
        [Parameter(Mandatory=$true)]
        [System.String]
        $projAuthor,
                
        # Comment
        [Parameter(Mandatory=$false)]
        [System.String]
        $projComment,

        # Description
        [Parameter(Mandatory=$true)]
        [System.String]
        $projDescription,
        
        # Project code
        [Parameter(Mandatory=$true)]
        [System.String]
        $projCode
        )

    # Create project directory
    Write-Verbose "Create project directory"
    if ( Test-Path ($dataTable.ProjectsRoot + $projName) )
    {
        $errorRes = "PROJECT FOLDER ALREADY EXISTS"
        Write-Verbose "PROJECT FOLDER ALREADY EXISTS`n`nFUNCTION WILL FINISH"
        continue
    } else {
        $res = New-Item -Path $dataTable.ProjectsRoot -ItemType directory -Name $projName

        # Write to Project Register
        Write-Verbose "Write to project registry ..."
        [xml]$projectRegister = Get-Content $dataTable.ProjectRegister
        $newProject = $projectRegister.ProjectRegister.AppendChild($projectRegister.CreateElement("Project"))
        # Name
        Write-Verbose "`t... Name ..."
        $newName = $newProject.AppendChild($projectRegister.CreateElement("Name"))
        $newNameText = $newName.AppendChild($projectRegister.CreateTextNode($projName))
        # Author
        Write-Verbose "`t... Author ..."
        $newAuthor = $newProject.AppendChild($projectRegister.CreateElement("Author"))
        $newAuthorText = $newAuthor.AppendChild($projectRegister.CreateTextNode($projAuthor))
        # Creation date
        Write-Verbose "`t... Creation date ..."
        $projDate = Get-Date -Format yyyyMMdd
        $newDate = $newProject.AppendChild($projectRegister.CreateElement("CreationDate"))
        $newDateText = $newDate.AppendChild($projectRegister.CreateTextNode($projDate))
        # Creation Time
        Write-Verbose "`t... Creation time ..."
        $projTime = Get-Date -Format HHmmss
        $newTime = $newProject.AppendChild($projectRegister.CreateElement("CreationTime"))
        $newTimeText = $newTime.AppendChild($projectRegister.CreateTextNode($projTime))
        # Comment
        Write-Verbose "`t... Comment ..."
        $newComment = $newProject.AppendChild($projectRegister.CreateElement("Comment"))
        $newCommentText = $newComment.AppendChild($projectRegister.CreateTextNode($projComment))
        # Description
        Write-Verbose "`t... Description ..."
        $newDescription = $newProject.AppendChild($projectRegister.CreateElement("Description"))
        $newDescriptionText = $newDescription.AppendChild($projectRegister.CreateTextNode($projDescription))
        # Location
        Write-Verbose "`t... Location ..."
        $projLocation = $res.FullName
        $newLocation = $newProject.AppendChild($projectRegister.CreateElement("Location"))
        $newLocationText = $newLocation.AppendChild($projectRegister.CreateTextNode($projLocation))
        # PID
        Write-Verbose "`t... PID ..."
        $projPID = $projCode + "-" + [guid]::NewGuid()
        $newPID = $newProject.AppendChild($projectRegister.CreateElement("PID"))
        $newPIDText = $newPID.AppendChild($projectRegister.CreateTextNode($projPID))
        # Asset count
        Write-Verbose "`t... Asset Count ..."
        $newAssetCount = $newProject.AppendChild($projectRegister.CreateElement("AssetCount"))
        $newAssetCountText = $newAssetCount.AppendChild($projectRegister.CreateTextNode("0"))

        # Save register
        Write-Verbose "Save register"
        $projectRegister.Save($dataTable.ProjectRegister)
    }

}
