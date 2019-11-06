$download_url = "https://github.com/cmderdev/cmder/releases/download/v1.3.12/cmder.zip"
$download_path = Join-Path (Resolve-Path .\).Path "cmder.zip"
$unpack_path = Join-Path (Resolve-Path .\).Path "cmder/"

# $client = new-object System.Net.WebClient
# $client.DownloadFile($download_url, $download_path)

function delete_file {
    param([string]$path)
    if (Test-Path $path) {
        Remove-Item $path -Force -Recurse
    }
}
function clean {
    "Removing old files"
    delete_file $unpack_path
    delete_file $download_path
}
function Download {
    param([string]$url, [string]$save_path)
    "Downloading cmder"
    $client = new-object System.Net.WebClient
    $client.DownloadFile($url, $save_path)
    "Download finished"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip {
    param([string]$zipfile, [string]$outpath)
    "Unpacking cmder"
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
    "Unpacking finished"
}
clean
Download $download_url $download_path
Unzip $download_path $unpack_path
"Removing downloaded file"
delete_file $download_path
