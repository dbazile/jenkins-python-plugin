#!/bin/bash -e


main() {
	fix_shebang
}


fix_shebang() {
	echo "Rewriting shebangs to use absolute path to Python on this machine"

	cd bin

	if [ -f python3 ]; then
		python_binary="python3"
	elif [ -f python2 ]; then
		python_binary="python2"
	else
		echo "Cannot find Python executable in $tool_root... Bailing"
		exit 1
	fi

	for f in *; do
		if [[ "$(file --mime $f)" =~ "binary" ]]; then
			continue
		fi

		sed -i.bak "s|^#!.*|#!${tool_root}/${python_binary}|" "$f"
		rm "$f.bak"
	done
}


main
