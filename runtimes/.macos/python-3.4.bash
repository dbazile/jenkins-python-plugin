#!/bin/bash -e

. "$(dirname $0)/_common.bash"

################################################################################

PYTHON_VERSION='3.4.7'
SOURCE_SHASUM='1614734847fd07e2a1ab1c65ae841db2433f8b845f49b34b7b5cabcb1c3f491f'

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
