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



#Validate FILE_PATH

if [ -z "$FILE_PATH" ]; then
	echo "Error: No file specified."
	show_help
	exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
	echo "Error: File '$FILE_PATH' not found."
	exit 1
fi

if [ ! -r "$FILE_PATH" ]; then
	echo "Error: File '$FILE_PATH' is not readable."
	exit 1
fi




#Uploading the file

FILE_NAME=$(basename "$FILE_PATH")
UPLOAD_OUTPUT=$(aws s3 cp "$FILE_PATH" "s3://$BUCKET_NAME/$TARGET_DIR/" -storage-class "$STORAGE_CLASS" 2>&1)

if [ $? -eq 0 ]; then
	echo "Upload successful! File available at s3://$BUCKET_NAME/$TARGET_DIR/$FILE_NAME"

	#Create a pre-signed URL
	PRESIGNED_URL=$(aws s3 presign "s3://$BUCKET_NAME/$TARGET_DIR/$FILE_NAME" --expires-in 3600)
	echo "Shareable link (valid for 1 hour): $PRESIGNED_URL"
else
	echo "Upload failed: $UPLOAD_OUTPUT"
	exit 1
fi
