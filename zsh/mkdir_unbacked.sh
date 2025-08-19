function mkdir_unbacked() {
	if (( ${+1} )); then
		mkdir -p "/home/.unbacked_files/${PWD#/home/}/$1"
		ln -s "/home/.unbacked_files/${PWD#/home/}/$1" "${PWD}/$1"
		return 0
	else
		echo "Directory name should be passed!"
		return 1
	fi
}
