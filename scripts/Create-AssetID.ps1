function Create-AssetID
{
    Param(
        [System.String]
        $projCode
    )

    . "C:\Users\ac00418\Documents\WindowsPowerShell\FunctionLibrary\FunctionScripts\Create-Random.ps1"

    $res = $projCode + "-"
    $res += (Create-Random -wordLength 8) + "-"
    $res += (Create-Random -wordLength 4) + "-"
    $res += (Create-Random -wordLength 4) + "-"
    $res += (Create-Random -wordLength 4) + "-"
    $res += (Create-Random -wordLength 12) + "-00"

    Write-Output $res
}
