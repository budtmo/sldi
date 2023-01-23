#!/bin/bash

if [ ! -d "./.git" ]; then
	echo "[ERROR] Working directory is not connected to git"; exit 1
fi

latest_tag=$(git tag | sort -V | tail -1)

#Create tag 0.1 if there is no latest tag found
if [ -z "${latest_tag}" ]; then
	echo "v0.1"
else
	if [ -z "$1" ]; then
	    read -p "Split format: " sf
	else
	    sf=$1
	fi

	IFS="${sf}" read -r -a array <<< "${latest_tag}"

	if [ -z "${array[1]}" ]; then
    	echo "[ERROR] String cannot be splitted"; exit 1
	fi

	re='^[0-9]+$'
	if ! [[ ${array[1]} =~ $re ]] ; then
	   echo "[ERROR] Last part of splitted string is not a number"; exit 1
	fi

	new_number=$((${array[1]}+1))
	echo ${array[0]}${sf}${new_number}
fi
