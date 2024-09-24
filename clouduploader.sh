#!/bin/bash

#CloudUploader CLI - Upload files to AWS S3

BUCKET_NAME="cloud-uploader"
DEFAULT_TARGET_DIR="uploads"
DEFAULT_STORAGE_CLASS="STANDARD_IA"



#function to display help

show_help() {

	echo "Usage: clouduploader [options] /path/to/file"
	echo ""
	echo "Options:"
	echo " -d, --directory    Target directory in S3 (default: $DEFAULT_TARGET_DIR)"
	echo " -s, --storage      Storage class (default: $DEFAULT_STORAGE_CLASS)"
	echo " -h, --help         Display this help message"
}


# Parse Arguments

POSITIONAL=()
while [[ $# -gt 0 ]]
do 
key="$1"

case $key in 
	-d|--directory)
	TARGET_DIR="$2"
	shift
	shift
	;;
	-s|--storage)
	STORAGE_CLASS="$2"
	shift
	shift
	;;
	-h|--help)
	show_help
	exit 0
	;;
	*)
	POSITIONAL+=("$1")
	shift
	;;
esac
done

#Restore positional parameters
set -- "${POSITIONAL[@]}"




#Assign positional arguments
FILE_PATH="$1"

#Set defaults if they werent provided

TARGET_DIR=${TARGET_DIR:-$DEFAULT_TARGET_DIR}
STORAGE_CLASS=${STORAGE_CLASS:-$DEFAULT_STORAGE_CLASS}


