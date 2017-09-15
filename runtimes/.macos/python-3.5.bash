#!/bin/bash -e

. "$(dirname $0)/_common.bash"

################################################################################

PYTHON_VERSION='3.5.4'
SOURCE_SHASUM='6ed87a8b6c758cc3299a8b433e8a9a9122054ad5bc8aad43299cff3a53d8ca44'

RUNTIME_NAME="python-${PYTHON_VERSION}-macos"
PIP_EXECUTABLE="pip${PYTHON_VERSION:0:1}"
PYTHON_EXECUTABLE="python${PYTHON_VERSION:0:1}"

################################################################################

print_header "$RUNTIME_NAME: started"

download_and_extract "$PYTHON_VERSION" "$SOURCE_SHASUM"

print_message 'compiling'

echo
print_border
	compile $RUNTIME_NAME
	install_pip $RUNTIME_NAME $PYTHON_EXECUTABLE $PIP_EXECUTABLE
	package $RUNTIME_NAME
print_border
echo

print_header "$RUNTIME_NAME: completed"
