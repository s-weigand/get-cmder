$download_url = "https://github.com/cmderdev/cmder/releases/download/v1.3.12/cmder.zip"
$download_path = Join-Path (Resolve-Path .\).Path "cmder.zip"
$unpack_path = Join-Path (Resolve-Path .\).Path "cmder/"
$custom_lua_conf_path_src = Join-Path (Resolve-Path .\).Path "custom_configs/clink.lua"
$custom_git_promt_conf_path_src = Join-Path (Resolve-Path .\).Path "custom_configs/git-prompt.sh"
$custom_lua_conf_path_dest = Join-Path $unpack_path "vendor/clink.lua"
$custom_git_promt_conf_path_dest = Join-Path $unpack_path "vendor/git-for-windows/etc/profile.d/git-prompt.sh"

function force_copy {
    param ( [string]$src, [string]$dest)
    Copy-Item $src $dest -force
}
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

"copy custom configs"
force_copy $custom_lua_conf_path_src $custom_lua_conf_path_dest
force_copy $custom_git_promt_conf_path_src $custom_git_promt_conf_path_dest
