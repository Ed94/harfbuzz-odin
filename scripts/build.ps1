$misc = join-path $PSScriptRoot 'helpers/misc.ps1'
. $misc

$path_root  = git rev-parse --show-toplevel
$path_lib   = join-path $path_root 'lib'
$path_win64 = join-path $path_lib  'win64'

$url_harfbuzz  = 'https://github.com/harfbuzz/harfbuzz.git'
$path_harfbuzz = join-path $path_root 'harfbuzz'

# Verify-Path   $path_harfbuzz
function build-repo {
	verify-path $script:path_lib
	verify-path $path_win64

	clone-gitrepo $path_harfbuzz $url_harfbuzz

	push-location $path_harfbuzz

	meson build --wrap-mode=default
	meson test -Cbuild

	pop-location

	$path_build = join-path $path_harfbuzz 'build'
	$path_src   = join-path $path_build    'src'
	$path_dll   = join-path $path_src      'harfbuzz.dll'
	$path_lib   = join-path $path_src      'harfbuzz.lib'
	$path_pdb   = join-path $path_src      'harfbuzz.pdb'

	copy-item -destination $path_win64 -path $path_dll -force
	copy-item -destination $path_win64 -path $path_lib -force
	copy-item -destination $path_win64 -path $path_pdb -force
}
Build-Repo

function grab-binaries {
	verify-path $script:path_lib
	verify-path $path_win64

	$url_harfbuzz_8_5_0_win64 = 'https://github.com/harfbuzz/harfbuzz/releases/latest/download/harfbuzz-win64-8.5.0.zip'
	$path_harfbuzz_win64_zip  = join-path $path_win64 'harfbuzz-win64-8.5.0.zip'
	$path_harfbuzz_win64      = join-path $path_win64 'harfbuzz-win64'

	grab-zip $url_harfbuzz_8_5_0_win64 $path_harfbuzz_win64_zip $path_win64
	get-childitem -path $path_harfbuzz_win64 | move-item -destination $path_win64 -force

	# Clean up the ZIP file and the now empty harfbuzz-win64 directory
	remove-item $path_harfbuzz_win64_zip -force
	remove-item $path_harfbuzz_win64 -recurse -force
}
# grab-binaries
