#!/bin/bash -e

cd $(dirname $(readlink $0 || echo $0))


TOOL_ROOT=$(pwd)


main() {
	fix_shebang
	make_read_only
}


fix_shebang() {
	echo "Rewriting shebangs to use absolute path to Python on this machine"

	cd "$TOOL_ROOT/bin"

	if [ -f python3 ]; then
		python_binary="python3"
	elif [ -f python2 ]; then
		python_binary="python2"
	else
		echo "Cannot find Python executable in $(pwd)... Bailing"
		exit 1
	fi

	for f in *; do
		if [[ "$(file --mime $f)" =~ "binary" ]]; then
			continue
		fi

		sed -i.bak "s|^#!.*|#!$(pwd)/${python_binary}|" "$f"
		rm "$f.bak"
	done

	cd "$TOOL_ROOT"
}


make_read_only() {
	chmod -R -w "$TOOL_ROOT"
}


main
