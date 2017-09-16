cd $(dirname $(dirname $(readlink $0 || echo $0)))  # Return to runtimes folder root

SCRIPTS_ROOT=$(pwd)
TARBALL_ROOT="$SCRIPTS_ROOT/.staging"
PYTHON_PIP_VERSION='9.0.1'

SOURCE_FOLDER=''


compile() {
	enter_source_folder

	local target_folder=$1

	set -ex

	./configure \
		--prefix="$(pwd)/$target_folder" \
		--with-ensurepip=install
	make
	make install

	set +x

	return_to_root
}


download_and_extract() {
	enter_workspace

	local url="https://www.python.org/ftp/python/$1/Python-$1.tgz"
	local file_hash="$2"
	local filename=$(basename $url)

	SOURCE_FOLDER=$(basename -s .tgz $filename)

	if [ ! -f "$filename" ]; then
		print_message "download $url"
		curl -fs -O "$url" || { echo "  !!!  error: download failed "; exit 1; }
	fi

	print_message "verifying hash"
	shasum -a 256 -c <(echo "$file_hash  $filename") 1>/dev/null

	print_message "extracting source tarball"
	rm -rf "$SOURCE_FOLDER"
	tar zxf "$filename"

	return_to_root
}


enter_source_folder() {
	cd "$SCRIPTS_ROOT/.macos/workspace/$SOURCE_FOLDER"
}


enter_workspace() {
	cd "$SCRIPTS_ROOT"
	mkdir -p .macos/workspace
	cd "$SCRIPTS_ROOT/.macos/workspace"
}


install_pip() {
	# Refer to https://github.com/docker-library/python/blob/d3c5f47b788adb96e69477dadfb0baca1d97f764/3.3/jessie/Dockerfile#L76-L85)

	enter_source_folder

	local target_folder=$1
	local python_executable=$2
	local pip_executable=$3

	set -x

	if [ -f "$target_folder/bin/$pip_executable" ]; then
		return
	fi

	curl -fs -O 'https://bootstrap.pypa.io/get-pip.py'

	"./$target_folder/bin/$python_executable" get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION"

	set +x

	return_to_root
}

package() {
	enter_source_folder

	local runtime_name=$1

	mkdir -p "$TARBALL_ROOT"

	cp $SCRIPTS_ROOT/_postinstall.bash "$runtime_name/postinstall.bash"

	tar zcf "$runtime_name.tar.gz" "$runtime_name"
	shasum -a 256 "$runtime_name.tar.gz" > "$runtime_name.tar.gz.shasum"

	mv "$runtime_name.tar.gz" "$runtime_name.tar.gz.shasum" "$TARBALL_ROOT"

	return_to_root
}


print_border() {
	echo "================================================================================"
}


print_header() {
	echo -e "  >>>  $@"
}


print_message() {
	echo -e "       $@"
}


return_to_root() {
	cd "$SCRIPTS_ROOT"
}


# This is less than ideal, but with MacOS Sierra not shipping with OpenSSL
# headers, this is the world we live in...
setup_openssl_headers() {
	enter_workspace

	local url="https://www.openssl.org/source/old/0.9.x/openssl-0.9.8zh.tar.gz"
	local filename=$(basename $url)
	local file_hash="f1d9f3ed1b85a82ecf80d0e2d389e1fda3fca9a4dba0bf07adbf231e1a5e2fd6"

	print_message "preparing openssl headers"

	if [ ! -f "$filename" ]; then
		print_message "download $url"
		curl -fs -O "$url" || { echo "  !!!  error: download failed "; exit 1; }

		print_message "verifying hash"
		shasum -a 256 -c <(echo "$file_hash  $filename") 1>/dev/null

		print_message "extracting source tarball"
		tar zxf "$filename"
	fi

	local openssl_source_abspath="$(pwd)/$(basename -s .tar.gz $filename)"
	if [ ! -d "$openssl_source_abspath/include/openssl" ]; then
		print_message "creating openssl header files at $openssl_source_abspath"

		print_border
		pushd $openssl_source_abspath >/dev/null

		set -ex

		./config --openssldir=/System/Library/OpenSSL

		set +x

		popd > /dev/null
		print_border

		echo
	fi

	export CFLAGS="-I$openssl_source_abspath/include"

	return_to_root
}


teardown_openssl_headers() {
	export CFLAGS=''
}
