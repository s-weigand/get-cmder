# General needed paths
$project_root = (Resolve-Path $PSScriptRoot\..\).Path
# $cmder_unpack_path = Join-Path $project_root "cmder/"
$cmder_unpack_path = Join-Path $env:USERPROFILE "cmder/"

# Paths only needed by download script
$zip_temp = Join-Path $project_root "temp.zip"
$download_cmder_url = "https://github.com//cmderdev/cmder/releases/download/v1.3.15/cmder.zip"
$download_make_url = "https://sourceforge.net/projects/ezwinports/files/make-4.3-without-guile-w32-bin.zip/download"
$cmder_executable_path = Join-Path $cmder_unpack_path "Cmder.exe"
$cmder_executable_path_escaped = "$([RegEx]::Escape($cmder_unpack_path))Cmder.exe"
$make_unpack_path = Join-Path $project_root "make/"
$make_dest_path = Join-Path $cmder_unpack_path "vendor/git-for-windows/mingw64"
$make_git_bash_install_path = "C:\Program Files\Git\mingw64"

# Paths only needed by config script

# SRC
$custom_lua_conf_path_src = Join-Path $project_root "custom_configs/clink.lua"
$custom_git_promt_conf_path_src = Join-Path $project_root "custom_configs/git-prompt.sh"
$custom_user_profile_src = Join-Path $project_root "custom_configs/user_profile.sh"
$custom_conemu_config_src = Join-Path $project_root "custom_configs/ConEmu.xml"

# DEST
$custom_lua_conf_path_dest = Join-Path $cmder_unpack_path "vendor/clink.lua"
$custom_git_promt_conf_path_dest = Join-Path $cmder_unpack_path "vendor/git-for-windows/etc/profile.d/git-prompt.sh"
$custom_user_profile_dest = Join-Path $cmder_unpack_path "config/user_profile.sh"
$custom_conemu_config_dest = Join-Path $cmder_unpack_path "vendor/conemu-maximus5/ConEmu.xml"
$default_conemu_config_dest = Join-Path $cmder_unpack_path "vendor/ConEmu.xml.default"

$temp_rc_file = Join-Path $project_root "/.bash_profile_tmp"
# $default_git_bash_config_path = Join-Path $project_root "/.bash_profile"
$default_git_bash_config_path = Join-Path $env:USERPROFILE ".bash_profile"

# DOWLOAD FUNCTIONS

function delete_file {
    param([string]$path)
    if (Test-Path $path) {
        "Deleting: $($path)"
        Remove-Item $path -Force -Recurse
    }
}
function clean {
    "Removing old files (This should only run during development)"
    delete_file $zip_temp
    delete_file $cmder_unpack_path
    delete_file $make_unpack_path
}

function write_reg_keys {
    "Writing Registry files to add and remove cmder from context menue"
    $add_cmder_context_entry_file = [System.IO.StreamWriter] "AddCmderContextMenueEntry.reg"
    $add_cmder_context_entry_file.WriteLine("Windows Registry Editor Version 5.00`n")
    $add_cmder_context_entry_file.WriteLine("[HKEY_CLASSES_ROOT\Directory\Background\shell\Cmder]")
    $add_cmder_context_entry_file.WriteLine("@=`"Open Cmder Here`"")
    $add_cmder_context_entry_file.WriteLine("`"Icon`"=`"$($cmder_executable_path_escaped),0`"`n")
    $add_cmder_context_entry_file.WriteLine("[HKEY_CLASSES_ROOT\Directory\Background\shell\Cmder\command]")
    $add_cmder_context_entry_file.WriteLine("@=`"\`"$($cmder_executable_path_escaped)\`" \`"%V\`"`"`n")
    $add_cmder_context_entry_file.WriteLine("[HKEY_CLASSES_ROOT\Directory\shell\Cmder]")
    $add_cmder_context_entry_file.WriteLine("@=`"Open Cmder Here`"")
    $add_cmder_context_entry_file.WriteLine("`"Icon`"=`"$($cmder_executable_path_escaped),0`"`n")
    $add_cmder_context_entry_file.WriteLine("[HKEY_CLASSES_ROOT\Directory\shell\Cmder\command]")
    $add_cmder_context_entry_file.WriteLine("@=`"\`"$($cmder_executable_path_escaped)\`" \`"%1\`"`"")
    $add_cmder_context_entry_file.close()

    $del_cmder_context_entry_file = [System.IO.StreamWriter] "RemoveCmderContextMenueEntry.reg"
    $del_cmder_context_entry_file.WriteLine("Windows Registry Editor Version 5.00`n")
    $del_cmder_context_entry_file.WriteLine("[-HKEY_CLASSES_ROOT\Directory\Background\shell\Cmder]")
    $del_cmder_context_entry_file.WriteLine("[-HKEY_CLASSES_ROOT\Directory\Background\shell\Cmder\command]")
    $del_cmder_context_entry_file.WriteLine("[-HKEY_CLASSES_ROOT\Directory\shell\Cmder]")
    $del_cmder_context_entry_file.WriteLine("[-HKEY_CLASSES_ROOT\Directory\shell\Cmder\command]")
    $del_cmder_context_entry_file.close()
}

function download_file {
    param([string]$url, [string]$save_path)
    "Downloading $($url) to $($save_path)"
    $client = new-object System.Net.WebClient
    $client.DownloadFile($url, $save_path)
    "Download finished"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
function unzip_file {
    param([string]$zipfile, [string]$outpath)
    "Unpacking $($zipfile) to $($outpath)"
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
    "Unpacking finished"
}

function download_and_unzip {
    param([string]$url, [string]$outpath)
    download_file $url $zip_temp
    unzip_file $zip_temp $outpath
    delete_file $zip_temp
}

# CONFIG FUNCTION DEFINITIONS

function force_copy_file {
    param ( [string]$src, [string]$dest)
    "Copying $($src) -> $($dest)"
    Copy-Item $src $dest -force
}

function ask_if_conda_is_used {
    param([string]$conf_file_path = $custom_user_profile_dest)
    $title = 'Is Conda Installed?'
    $question = 'Do you want to use Anaconda?'
    $choices = '&Yes', '&No'

    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
    if ($decision -eq 0) {
        select_conda_path $conf_file_path
    }
}
function select_conda_path {
    param([string]$conf_file_path)

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select the folder Anaconda is installed into"
    $foldername.rootfolder = "MyComputer"

    $folder_select_response = $foldername.ShowDialog()

    if ($folder_select_response -eq "OK") {
        $conda_folder = $foldername.SelectedPath
        if (!(validate_conda_dir $conda_folder)) {
            [System.Windows.Forms.MessageBox]::Show("The chosen folder isn't an Anaconda installation root folder.", "Wrong folder", 0)
            select_conda_path $conf_file_path
        }
        else {
            add_conda_default_path $conda_folder
        }
    }
    return $folder_select_response
}

function add_conda_default_path {
    param([string]$conda_folder)
    $CONDA_PATHS = generate_conda_paths $conda_folder
    $title = 'Add Conda to path?'
    $question = 'Do you want to add Anaconda to your PATH variable?'
    $choices = '&Yes', '&No'

    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)

    "Added 'conda_add_path' function to add all needed paths for the "
    "full conda functionality and make the conda python the default python."
    Add-Content $conf_file_path "# BEGIN GET-CMDER CONDA CONFIG"
    Add-Content $conf_file_path "# Dont add configuration after this part, since it will be deleted on reconfigure"
    Add-Content $conf_file_path "export CONDA_ROOT_DIR='$($conda_folder)'"
    Add-Content $conf_file_path "export INITIAL_PATH=`$PATH"
    Add-Content $conf_file_path "conda_add_path(){"
    Add-Content $conf_file_path "    echo Added conda paths to cmder PATH variable, call `'conda_remove_path`' to restore the default PATH variable"
    Add-Content $conf_file_path "    export PATH=`"$($CONDA_PATHS):`$PATH`""
    Add-Content $conf_file_path "}"
    "To not use condas python as default python run 'conda_remove_path'."
    Add-Content $conf_file_path "conda_remove_path(){"
    Add-Content $conf_file_path "    echo Restored default PATH variable, call `'conda_add_path`' to use conda"
    Add-Content $conf_file_path "    export PATH=`"`$INITIAL_PATH`""
    Add-Content $conf_file_path "}"
    if ($decision -eq 0) {
        Add-Content $conf_file_path "conda_add_path"
    }
    Add-Content $conf_file_path "# END GET-CMDER CONDA CONFIG"
}

function strip_conda_config {
    if (Test-Path $default_git_bash_config_path) {
        $original_config = Get-Content $default_git_bash_config_path -Raw
    }
    else {
        $original_config = ""
    }
    $stripped_config = $original_config -replace "(?s)# BEGIN GET-CMDER CONDA CONFIG.+# END GET-CMDER CONDA CONFIG", ""
    Set-Content -Path $temp_rc_file -Value $stripped_config
    $cmder_default_config = Get-Content $custom_user_profile_src -Raw
    Add-Content $temp_rc_file "# BEGIN GET-CMDER CONDA CONFIG"
    Add-Content $temp_rc_file "# Dont add configuration after this part, since it will be deleted on reconfigure"
    Add-Content $temp_rc_file $cmder_default_config
    Add-Content $temp_rc_file "# END GET-CMDER CONDA CONFIG"
}

function generate_conda_paths {
    param([string]$conda_dir)
    $conda_dir = (($conda_dir -replace "\\", "/") -replace ":", "").ToLower().Trim("/")
    $conda_dir = "/$($conda_dir)"
    $CONDA_PATHS = "$($conda_dir)"
    $CONDA_PATHS = "$($conda_dir)/Library/mingw-w64/bin:$($CONDA_PATHS)"
    $CONDA_PATHS = "$($conda_dir)/Library/usr/bin:$($CONDA_PATHS)"
    $CONDA_PATHS = "$($conda_dir)/Library/bin:$($CONDA_PATHS)"
    $CONDA_PATHS = "$($conda_dir)/Scripts:$($CONDA_PATHS)"
    return $CONDA_PATHS
}

function validate_conda_dir {
    param([string]$conda_dir)
    $python_executable = Join-Path $conda_dir "Python.exe"
    $conda_executable = Join-Path $conda_dir "Scripts/conda.exe"
    return ((Test-Path $python_executable) -and (Test-Path $conda_executable))
}

function copy_custom_configs {
    "Copy custom configs"
    force_copy_file $custom_lua_conf_path_src $custom_lua_conf_path_dest
    force_copy_file $custom_git_promt_conf_path_src $custom_git_promt_conf_path_dest
    force_copy_file $custom_user_profile_src $custom_user_profile_dest
    force_copy_file $custom_conemu_config_src $custom_conemu_config_dest
    force_copy_file $custom_conemu_config_src $default_conemu_config_dest
}

# MAKE INSTALLATION

function  copy_make {
    param ([string]$dest_path)
    Copy-Item -Path "$($make_unpack_path)\bin\*" -Destination "$($dest_path)\bin" -Recurse
    Copy-Item -Path "$($make_unpack_path)\include\*" -Destination "$($dest_path)\include" -Recurse
    Copy-Item -Path "$($make_unpack_path)\lib\*" -Destination "$($dest_path)\lib" -Recurse
    Copy-Item -Path "$($make_unpack_path)\share\doc\*" -Destination "$($dest_path)\share\doc" -Recurse
    Copy-Item -Path "$($make_unpack_path)\share\info\*" -Destination "$($dest_path)\share\info" -Recurse
    Copy-Item -Path "$($make_unpack_path)\share\man\cat1" -Destination "$($dest_path)\share\man" -Recurse
    Copy-Item -Path "$($make_unpack_path)\share\man\man1\*" -Destination "$($dest_path)\share\man\man1" -Recurse
    delete_file $make_unpack_path
}
