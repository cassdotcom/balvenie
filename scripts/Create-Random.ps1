function Create-Random
{
    Param(
        [System.Int32]
        $wordLength
    )
    $n = 1

    $set = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".ToCharArray()

    $res = $set | Get-Random

    while ( $n -le $wordLength ) {
        $res += $set | Get-Random
        $n++
    }

    Write-Output $res
}
