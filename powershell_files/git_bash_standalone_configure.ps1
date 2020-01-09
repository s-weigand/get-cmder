. $PSScriptRoot\function_definitions.ps1

strip_conda_config
ask_if_conda_is_used $temp_rc_file
force_copy_file  $temp_rc_file $default_git_bash_config_path

# delete_file $temp_rc_file
