#!/bin/bash

PASS="{{command_output "secret-tool lookup dotter password"}}"

for file in $PWD/.dotter/private/*.toml
do
	# This check is used to avoid reencryption of unchanged files
	if test -f "$file.asc"
	then
		gpg --armor --batch --yes --passphrase $PASS --decrypt  "$file.asc" | diff -N $file - > /dev/null
		if [ $? -eq 0 ]
		then
			continue
		fi
	fi

	gpg --armor --batch --yes --passphrase $PASS --symmetric $file
done

