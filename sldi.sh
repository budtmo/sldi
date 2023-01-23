#!/bin/bash


if [ -z "$1" ]; then
    read -p "Image name (e.g. ubuntu): " img
else
    img=$1
fi

if [ -z "$2" ]; then
    read -p "Used image tag (e.g. bionic-20220801): " ut
else
    ut=$2
fi

if [ -z "$3" ]; then
    read -p "Latest image tag (e.g. bionic): " lt
else
    lt=$3
fi

used_img=${img}:${ut}
echo "Used image: ${used_img}"

latest_img=${img}:${lt}
echo "Latest image: ${latest_img}"

# Pull both images
docker pull ${used_img} 
docker pull ${latest_img}

# Get sha256 from both images
sha_used_img=$(docker inspect ${used_img} | jq '.[] | .RepoDigests | .[]' | tr -d '"' | cut -d'@' -f2)
echo "sha256 of used image: ${sha_used_img}"
sha_latest_img=$(docker inspect ${latest_img} | jq '.[] | .RepoDigests | .[]' | tr -d '"' | cut -d'@' -f2)
echo "sha256 of latest image: ${sha_latest_img}"

# Compare sha256 of both images
if [[ "${sha_used_img}" == "${sha_latest_img}" ]]; then
    echo "Used docker image is the latest image"
else
    echo "Both images are not equal. There is a new version of image. Search the latest image tag..."

    if [ -z "$4" ]; then
        read -p "Wished format of docker image (e.g. bionic-): " format
    else
        format=$4
    fi

    docker_registry_url="https://registry.hub.docker.com/v2/repositories/library/${img}/tags"
    tmp_file="tmp-sldi.txt"

    # Get the correct image tag based on the given format
    latest_img_name=${img}:$(curl -s ${docker_registry_url} \
    | jq --arg sha_latest_img "$sha_latest_img" --arg format "$format" '.results | .[] | select(.digest==$sha_latest_img) | select(.name | startswith($format)) | .name' | tr -d '"')
    echo "The latest image name: ${latest_img_name}. It is stored under ${tmp_file}"
    echo "${latest_img_name}" > ${tmp_file}
fi
