#!/bin/bash -e

cd "$(dirname $0)"
RUNTIME_ROOT="$(pwd)"



echo -e "\nDetermining absolute path to Python executable...\n"

cd "$RUNTIME_ROOT/bin"
if [ -f 'python3' ]; then
	PYTHON_BIN="$(pwd)/python3"
elif [ -f 'python2' ]; then
	PYTHON_BIN="$(pwd)/python2"
else
	echo "error: can't find Python executable in $(pwd)..."
	exit 1
fi
cd "$RUNTIME_ROOT"



echo -e "\nRewriting shebangs to $PYTHON_BIN...\n"

for f in bin/*; do
	if [[ "$(file --mime $f)" =~ "binary" ]]; then
		echo "       skip $f"
		continue
	fi

	echo "    rewrite $f"
	sed -i.bak "s|^#!.*|#!${PYTHON_BIN}|" "$f"
	rm "$f.bak"
done



echo -e "\nMaking $RUNTIME_ROOT read-only...\n"

chmod -R -w "$RUNTIME_ROOT"
