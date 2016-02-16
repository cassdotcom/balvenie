function Create-AssetID
{
    . "C:\Users\ac00418\Documents\WindowsPowerShell\FunctionLibrary\FunctionScripts\Create-Random.ps1"

    $res = (Create-Random -wordLength 8) + "-"
    $res += (Create-Random -wordLength 4) + "-"
    $res += (Create-Random -wordLength 4) + "-"
    $res += (Create-Random -wordLength 8)

    Write-Output $res
}
