# See https://stackoverflow.com/a/7475744/2400463

function Copy-ObjectDeeply
{
    param($DeepCopyObject)
    $memStream = New-Object IO.MemoryStream
    $formatter = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter
    $formatter.Serialize($memStream, $DeepCopyObject)
    $memStream.Position = 0
    $formatter.Deserialize($memStream)
}
