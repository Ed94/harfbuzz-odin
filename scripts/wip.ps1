$misc = join-path $PSScriptRoot 'helpers/misc.ps1'
. $misc

$path_root = git rev-parse --show-toplevel

$url_harfbuzz  = 'https://github.com/harfbuzz/harfbuzz.git'
$path_harfbuzz = join-path $path_root 'harfbuzz'

# Verify-Path   $path_harfbuzz
Clone-Gitrepo $path_harfbuzz $url_harfbuzz


