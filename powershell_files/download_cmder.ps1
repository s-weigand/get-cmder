. $PSScriptRoot\function_definitions.ps1

clean
download_and_unzip $download_cmder_url $cmder_unpack_path
download_and_unzip $download_make_url $make_unpack_path
copy_make $make_dest_path

