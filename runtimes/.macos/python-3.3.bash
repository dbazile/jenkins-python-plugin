#!/bin/bash -e

. "$(dirname $0)/_common.bash"

################################################################################

PYTHON_VERSION='3.3.6'
SOURCE_SHASUM='0a58ad1f1def4ecc90b18b0c410a3a0e1a48cf7692c75d1f83d0af080e5d2034'

RUNTIME_NAME="python-${PYTHON_VERSION}-macos"
PIP_EXECUTABLE="pip${PYTHON_VERSION:0:1}"
PYTHON_EXECUTABLE="python${PYTHON_VERSION:0:1}"

################################################################################

print_header "$RUNTIME_NAME: started"

download_and_extract "$PYTHON_VERSION" "$SOURCE_SHASUM"

setup_openssl_headers

print_message 'compiling'

echo
print_border
	compile $RUNTIME_NAME
	install_pip $RUNTIME_NAME $PYTHON_EXECUTABLE $PIP_EXECUTABLE
	package $RUNTIME_NAME
print_border
echo

teardown_openssl_headers

print_header "$RUNTIME_NAME: completed"
