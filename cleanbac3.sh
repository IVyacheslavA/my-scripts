#!/bin/bash
#set -x

rmfiles="*.bac *.backup *.tmp"
checkkeys="-d -r -w -x"

if [[ $# -eq 0 ]]
then
	echo "ERROR: Please enter the directory's as a parameters"
	exit 1
fi
cd
printerror() {
case "$key" in
"-d") echo "ERROR: "$dir" doesn't exist or not a directory" && exit 2;;
"-r") echo "ERROR: can't read "$dir" (permission denied)" && exit 3;;
"-w") echo "ERROR: can't write in "$dir" (permission denied)" && exit 3;;
"-x") echo "ERROR: can't exec in "$dir" (permission denied)" && exit 3;;
*) echo "Something went wrong" && exit 4;;
esac
}

checkdir() {
for key in $checkkeys
do
	if [ ! $key "$dir" ]
	then
		printerror "$key"
fi
done
}


cleandir() {
for filebac in $rmfiles
do
	rm "$dir/"$filebac && echo "$filebac in "$dir" succesfully removed"
done
}


for dir in $@
do
	checkdir
	cleandir
done



