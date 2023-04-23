#!/bin/bash

#set -x

sestat="SELinux status"
curmode="Current mode"
confmode="Mode from config file"
i=0
mode=""
ex=0

setconf() {
curconf=$(grep "^SELINUX=" /etc/selinux/config)
sed -i.bac "s/$curconf/SELINUX=$mode/" /etc/selinux/config && awk '/^SELINUX=/{print}' /etc/selinux/config
}

changeconfig() {
echo
echo "You can choose:"
case ${sestatus[$confmode]} in
"disabled") answer1='enforcing_mode' answer2='permissive_mode' firstaction="eval mode=enforcing" secondaction="eval mode=permissive" menu $firstaction $secondaction $answer1 $answer2;;
"enforcing") answer1='disabled_mode' answer2='permissive_mode' firstaction="eval mode=disabled" secondaction="eval mode=permissive" menu $firstaction $secondaction $answer1 $answer2;;
"permissive") answer1='disabled_mode' answer2='enforcing_mode' firstaction="eval mode=disabled" secondaction="eval mode=enforcing" menu $firstaction $secondaction $answer1 $answer2;;
*) echo "ERROR: Unknown SElinux config mode" && exit 1;;
esac
setconf $mode
}

menu() {
PS3="Enter 1 or 2: "
select answer in $answer1 $answer2
do
case $answer in
"$answer1") $firstaction;;
"$answer2") $secondaction;;
*) echo "Unknown operator" && continue;;
esac
break
done
}

changecurmode() {
case ${sestatus[$curmode]} in
"disabled") echo "Can't change current mode because SElinux is disabled.";;
"enforcing") setenforce 0 && echo "Current mode sucessfully changed to permissive";;
"permissive") setenforce 1 && echo "Current mode sucessfully changed to enforcing";;
*) echo "ERROR: Unknown SElinux current mode" && exit 1;;
esac
}

checkchanges() {
if [ $(awk '/^SELINUX=/{print}' /etc/selinux/config) != $(awk '/^SELINUX=/{print}' /etc/selinux/config.bac) ] 
then
	echo
	echo "The configuration changes will take effect after the computer is restarted."
	echo "Do you want to restart PC?"
	answer1="yes"
	answer2="no"
	firstaction="reboot"
	secondaction=":"
	menu $firstaction $secondaction $answer1 $answer2
fi
}

checkroot() {
if [ $UID -ne 0 ]
then
       echo
	echo "Superuser privileges are required for this script"
	echo
       ex=1
	sudo -k  ~/bashsc/seswitch2.sh -n
fi
}

changeset() {
checkroot
if [ $ex -eq 1 ]
then
	checkchanges
	exit 0
fi
echo

echo "Would you want to change current mode? (if SElinux disabled can't change current mode):"
echo
firstaction="changecurmode"
secondaction=":"
answer1="yes"
answer2="no"
menu $firstaction $secondaction $answer1 $answer2

echo
echo "Would you want to change mode from config file?(yes/no): "
firstaction="changeconfig"
secondaction=":"
answer1="yes"
answer2="no"

menu $firstaction $secondaction $answer1 $answer2
}

message() {
echo
echo
echo "Current settings SElinux:"
echo "------------------------"

for word in "${!sestatus[@]}"
do
	echo
	echo "$word  -  "${sestatus[$word]}""
	echo
done
echo "------------------------"
echo
echo "Would you want to change it?"

firstaction="changeset"
secondaction="exit"
answer1="yes"
answer2="no"

menu $firstaction $secondaction $answer1 $answer2
}


filling() {

declare -A sestatus
sestatus["$confmode"]=$(grep "^SELINUX=" /etc/selinux/config | awk -F "=" '{print $2}')

if [ "${sestatus["$confmode"]}" = "disabled" ]
then
	sestatus["$sestat"]="disabled"
else
	sestatus["$sestat"]="enabled"
fi

sestatus["$curmode"]=$(getenforce | tr [:upper:] [:lower:])

if [ "$1" = "-n" ]
then
ex=0
changeset
else
message	
fi
}

filling "$1"


