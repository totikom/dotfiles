#!/bin/bash

PASS="{{command_output "secret-tool lookup dotter password"}}"

for file in $PWD/.dotter/private/*.asc
do
	# If there are any patch files, abort
	if test -f "${file%.*}.patch"
	then
		echo "$(basename -- "${file%.*}").patch exists."
		echo "resolve conflicts before deploy"
		exit 1
	fi

	# decrypt and diff with the existing file
	gpg --armor --batch --yes --passphrase $PASS --decrypt  $file | diff -N "${file%.*}" - > "${file%.*}.patch"
	if [ $? -eq 0 ]
	then
		# if the file wasn't changed, there will be an empty patch file
		# delete it
		rm "${file%.*}.patch"
	else
		# abort in case of any errors in diff
		if [ $? -eq 2 ]
		then
			exit 1
		fi
	fi
done
