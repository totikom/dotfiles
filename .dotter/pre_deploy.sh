#!/bin/bash

PASS="{{command_output "secret-tool lookup dotter password"}}"

for file in $PWD/.dotter/private/*.asc
do
	# If there are any new files, abort
	if test -f "${file%.*}.new"
	then
		echo "$(basename -- "${file%.*}").new exists."
		echo "resolve conflicts before deploy"
		exit 1
	fi

	# decrypt and diff with the existing file
	gpg --armor --batch --yes --passphrase $PASS --decrypt  $file > "${file%.*}.new"

	diff -N "${file%.*}" "${file%.*}.new"
	if [ $? -eq 0 ]
	then
		# if the file wasn't changed, remove .new file
		rm "${file%.*}.new"
	else
		# abort in case of any errors in diff
		if [ $? -eq 2 ]
		then
			exit 1
		fi
	fi
done
