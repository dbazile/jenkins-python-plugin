 #!/bin/bash -e

. "$(dirname $0)/_common.bash"

################################################################################

PYTHON_VERSION='2.7.13'
SOURCE_SHASUM='a4f05a0720ce0fd92626f0278b6b433eee9a6173ddf2bced7957dfb599a5ece1'

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
	"./$RUNTIME_NAME/bin/$PIP_EXECUTABLE" install virtualenv
	package $RUNTIME_NAME
print_border
echo

print_header "$RUNTIME_NAME: completed"
