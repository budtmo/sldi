#!/bin/bash

if [ -z "${1}" ]; then
	read -p "Action (get|replace) : " ACTION
else
	ACTION=${1}
fi

function get() {
	if [ -z "${1}" ]; then
		read -p "Dockerfile path : " path
	else
		path=${1}
	fi

	if [ -f "${path}" ]; then
		base_img=$(cat ${path} | grep FROM | cut -d' ' -f2)
		echo ${base_img}
	else
		echo "${path} doesnt exist. Please check again!"
		exit -1
	fi
}

function replace() {
	if [ -z "${1}" ]; then
		read -p "old image : " old
	else
		old=${1}
	fi

	if [ -z "${2}" ]; then
		read -p "new image : " new
	else
		new=${2}
	fi

	if [ -z "${3}" ]; then
		read -p "Dockerfile path : " path
	else
		path=${3}
	fi

	echo ${old} ${new}

	if [ -f "${path}" ]; then
		sed -i "s/${old}/${new}/g" ${path}
	else
		echo "${path} doesnt exist. Please check again!"
		exit -1
	fi
}

case ${ACTION} in
get)
	get ${2}
	;;
replace)
	replace ${2} ${3} ${4}
	;;
*)
	echo "Invalid action! Valid options: get, replace"
	;;
esac
