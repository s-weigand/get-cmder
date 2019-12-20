. $PSScriptRoot\path_definitions.ps1

function delete_file {
    param([string]$path)
    if (Test-Path $path) {
        "Deleting: $($path)"
        Remove-Item $path -Force -Recurse
    }
}
function clean {
    "Removing old files"
    delete_file $unpack_path
    delete_file $download_path
}

function write_reg_keys {
    $add_cmder_context_entry_file = [System.IO.StreamWriter] "AddCmderContextMenueEntry.reg"
    $add_cmder_context_entry_file.WriteLine("Windows Registry Editor Version 5.00`n")
    $add_cmder_context_entry_file.WriteLine("[HKEY_CLASSES_ROOT\Directory\Background\shell\Cmder]")
    $add_cmder_context_entry_file.WriteLine("@=`"Open Cmder Here`"")
    $add_cmder_context_entry_file.WriteLine("`"Icon`"=`"$($cmder_executable_path_escaped),0`"`n")
    $add_cmder_context_entry_file.WriteLine("[HKEY_CLASSES_ROOT\Directory\Background\shell\Cmder\command]")
    $add_cmder_context_entry_file.WriteLine("@=`"\`"$($cmder_executable_path_escaped)`" \`"%V\`"`"`n")
    $add_cmder_context_entry_file.WriteLine("[HKEY_CLASSES_ROOT\Directory\shell\Cmder]")
    $add_cmder_context_entry_file.WriteLine("@=`"Open Cmder Here`"")
    $add_cmder_context_entry_file.WriteLine("`"Icon`"=`"$($cmder_executable_path_escaped),0`"`n")
    $add_cmder_context_entry_file.WriteLine("[HKEY_CLASSES_ROOT\Directory\shell\Cmder\command]")
    $add_cmder_context_entry_file.WriteLine("@=`"\`"$($cmder_executable_path_escaped)`" \`"%1\`"`"")
    $add_cmder_context_entry_file.close()

    $del_cmder_context_entry_file = [System.IO.StreamWriter] "RemoveCmderContextMenueEntry.reg"
    $del_cmder_context_entry_file.WriteLine("Windows Registry Editor Version 5.00`n")
    $del_cmder_context_entry_file.WriteLine("[-HKEY_CLASSES_ROOT\Directory\Background\shell\Cmder]")
    $del_cmder_context_entry_file.WriteLine("[-HKEY_CLASSES_ROOT\Directory\Background\shell\Cmder\command]")
    $del_cmder_context_entry_file.WriteLine("[-HKEY_CLASSES_ROOT\Directory\shell\Cmder]")
    $del_cmder_context_entry_file.WriteLine("[-HKEY_CLASSES_ROOT\Directory\shell\Cmder\command]")
    $del_cmder_context_entry_file.close()
}

function Download {
    param([string]$url, [string]$save_path)
    "Downloading cmder to $($save_path)"
    $client = new-object System.Net.WebClient
    $client.DownloadFile($url, $save_path)
    "Download finished"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip {
    param([string]$zipfile, [string]$outpath)
    "Unpacking cmder to $($outpath)"
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
    "Unpacking finished"
}

clean
Download $download_url $download_path
Unzip $download_path $unpack_path
"Removing downloaded file"
delete_file $download_path

