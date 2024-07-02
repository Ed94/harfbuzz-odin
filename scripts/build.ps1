$misc = join-path $PSScriptRoot 'helpers/misc.ps1'
. $misc

$path_root  = git rev-parse --show-toplevel
$path_lib   = join-path $path_root 'lib'
$path_win64 = join-path $path_lib  'win64'

$url_harfbuzz  = 'https://github.com/harfbuzz/harfbuzz.git'
$path_harfbuzz = join-path $path_root 'harfbuzz'

function build-repo {
	verify-path $script:path_lib
	verify-path $path_win64

	clone-gitrepo $path_harfbuzz $url_harfbuzz

	push-location $path_harfbuzz

    $library_type = "shared"
    $build_type   = "release"

    # Meson configure and build
    $mesonArgs = @(
        "build",
        "--default-library=$library_type",
        "--buildtype=$build_type",
        "--wrap-mode=forcefallback",
        "-Dglib=disabled",
        "-Dgobject=disabled",
        "-Dcairo=disabled",
        "-Dicu=disabled",
        "-Dgraphite=disabled",
        "-Dfreetype=disabled",
        "-Ddirectwrite=disabled",
        "-Dcoretext=disabled"
    )
    & meson $mesonArgs
	& meson compile -C build

	pop-location

	$path_build      = join-path $path_harfbuzz 'build'
	$path_src        = join-path $path_build    'src'
	$path_dll        = join-path $path_src      'harfbuzz.dll'
	$path_lib        = join-path $path_src      'harfbuzz.lib'
	$path_lib_static = join-path $path_src      'libharfbuzz.a'
	$path_pdb        = join-path $path_src      'harfbuzz.pdb'

	# Copy files based on build type and library type
	if ($build_type -eq "debug") {
		copy-item -Path $path_pdb -Destination $path_win64 -Force
	}

	if ($library_type -eq "static") {
		copy-item -Path $path_lib_static -Destination (join-path $path_win64 'harfbuzz.lib') -Force
	}
	else {
		copy-item -Path $path_lib -Destination $path_win64 -Force
		copy-item -Path $path_dll -Destination $path_win64 -Force
	}

	write-host "Build completed and files copied to $path_win64"
}
build-repo

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
