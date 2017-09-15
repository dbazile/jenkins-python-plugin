#!/bin/bash -e

. "$(dirname $0)/_common.bash"

################################################################################

PYTHON_VERSION='3.6.2'
SOURCE_SHASUM='7919489310a5f17f7acbab64d731e46dca0702874840dadce8bd4b2b3b8e7a82'

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
