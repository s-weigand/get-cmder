. $PSScriptRoot\path_definitions.ps1

function force_copy {
    param ( [string]$src, [string]$dest)
    "Copying $($src) -> $($dest)"
    Copy-Item $src $dest -force
}

function ask_if_conda_is_used {
    $title = 'Conda?'
    $question = 'Are you using Anaconda?'
    $choices = '&Yes', '&No'

    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        add_conda_path
    }
}
function add_conda_path {

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select the folder Anaconda is installed into"
    $foldername.rootfolder = "MyComputer"

    if ($foldername.ShowDialog() -eq "OK") {
        $conda_folder = $foldername.SelectedPath
        Add-Content $custom_user_profile_dest "export CONDA_ROOT_DIR='$($conda_folder)'"
        if (!(validate_conda_dir $conda_folder)) {
            [System.Windows.Forms.MessageBox]::Show("The chosen folder isn't an Anaconda installation root folder.", "Wrong folder", 0)
            add_conda_path
        }
    }
}

function validate_conda_dir {
    param([string]$conda_dir)
    $python_executable = Join-Path $conda_dir "Python.exe"
    $conda_executable = Join-Path $conda_dir "Scripts/conda.exe"
    return ((Test-Path $python_executable) -and (Test-Path $conda_executable))
}

function copy_custom_configs {
    "Copy custom configs"
    force_copy $custom_lua_conf_path_src $custom_lua_conf_path_dest
    force_copy $custom_git_promt_conf_path_src $custom_git_promt_conf_path_dest
    force_copy $custom_user_profile_src $custom_user_profile_dest
    force_copy $custom_conemu_config_src $custom_conemu_config_dest
    force_copy $custom_conemu_config_src $default_conemu_config_dest
}

copy_custom_configs
ask_if_conda_is_used
