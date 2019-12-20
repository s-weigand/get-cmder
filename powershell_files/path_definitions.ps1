# General needed paths
$project_root = (Resolve-Path $PSScriptRoot\..\).Path
$unpack_path = Join-Path $project_root "cmder/"

# Paths only needed by download script
$download_url = "https://github.com/cmderdev/cmder/releases/download/v1.3.12/cmder.zip"
$download_path = Join-Path $project_root "cmder.zip"
$cmder_executable_path = Join-Path $unpack_path "Cmder.exe"
$cmder_executable_path_escaped = "$([RegEx]::Escape($unpack_path))Cmder.exe"

# Paths only needed by config script

# SRC
$custom_lua_conf_path_src = Join-Path $project_root "custom_configs/clink.lua"
$custom_git_promt_conf_path_src = Join-Path $project_root "custom_configs/git-prompt.sh"
$custom_user_profile_src = Join-Path $project_root "custom_configs/user_profile.sh"
$custom_conemu_config_src = Join-Path $project_root "custom_configs/ConEmu.xml"

# DEST
$custom_lua_conf_path_dest = Join-Path $unpack_path "vendor/clink.lua"
$custom_git_promt_conf_path_dest = Join-Path $unpack_path "vendor/git-for-windows/etc/profile.d/git-prompt.sh"
$custom_user_profile_dest = Join-Path $unpack_path "config/user_profile.sh"
$custom_conemu_config_dest = Join-Path $unpack_path "vendor/conemu-maximus5/ConEmu.xml"
$default_conemu_config_dest = Join-Path $unpack_path "vendor/ConEmu.xml.default"
