#!/bin/bash

#CloudUploader CLI - Upload files to AWS S3

BUCKET_NAME="your-bucket-name"
DEFAULT_TARGET_DIR="uploads"
DEFAULT_STORAGE_CLASS="STANDARD"
ECRYPTION_PASSWORD="your-password"



#function to display help

show_help() {

	echo "Usage: clouduploader [options] /path/to/file"
	echo ""
	echo "Options:"
	echo " -d, --directory    Target directory in S3 (default: $DEFAULT_TARGET_DIR)"
	echo " -s, --storage      Storage class (default: $DEFAULT_STORAGE_CLASS)"
	echo " -e, --encrypt      Encrypt the file before upload"
	echo " -h, --help         Display this help message"
}


# Parse Arguments

POSITIONAL=()
ENCRYPT_FILE=false
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
	-e|--encrypt)
	ENCRYPT_FILE=true
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


#Encrypt the file if requested
if $ENCRYPT_FILE; then
	ENCRYPTED_FILE="${FILE_PATH}.enc"
	openssl enc -aes-256-cbc -salt -in "$FILE_PATH" -out "$ENCRYPTED_FILE" -k "$ENCRYPTION_PASSWORD"
	FILE_PATH="$ENCRYPTED_FILE"
	echo "File encrypted as $ENCRYPTED_FILE"
fi



#Check to see if the file already exists in the target directoy on S3

FILE_NAME=$(basename "$FILE_PATH")
EXISTS=$(aws s3 ls "s3://$BUCKET_NAME/$TARGET_DIR/$FILE_NAME")

if [ -n "$EXISTS" ]; then
	echo "File '$FILE_NAME' already exists in the s3 bucket."
	echo "Do you want to (O)verwrite, (S)kip, or (R)ename the file?"
	read -p "[O/S/R]: " choice
	case "$choice" in
		O|o)
			echo "Overwriting the file..."
			;;
		S|s)
			echo "Skipping the upload."
			exit 0
			;;
		R|r)
			read -p "Enter the new file name: " NEW_FILE_NAME
			FILE_NAME="$NEW_FILE_NAME"
			;;
		*)
			echo "Invalid choice. Exiting."
			exit 1
			;;
	esac
fi
	


#Uploading the file

FILE_NAME=$(basename "$FILE_PATH")

if command -v pv &> /dev/null; then
	#Use pv for progress bar 
	UPLOAD_OUTPUT=$(pv "$FILE_PATH" | aws s3 cp - "s3://$BUCKET_NAME/$TARGET_DIR/$FILE_NAME" --storage-class "$STORAGE_CLASS" 2>&1)
else
	#Fallback if pv is not installed
	echo "pv is not installed. Uploadingg without progress bar."
	UPLOAD_OUTPUT=$(aws s3 cp "$FILE_PATH" "s3://$BUCKET_NAME/$TARGET_DIR/" --storage-class "$STORAGE_CLASS" 2>&1)
fi

if [ $? -eq 0 ]; then
	echo "Upload successfil! File available at s3://$BUCKET_NAME/$TARGET_DIR/$FILE_NAME"

	# Generate the pre-signed URL
	PRESIGNED_URL=$(aws s3 presign "s3://$BUCKET_NAME/$TARGET_DIR/$FILE_NAME" --expires-in 3600)
	echo "Shareable link (valid for 1 hour): $PRESIGNED_URL"
else
	echo "Upload failed: $UPLOAD_OUTPUT"
	exit 1
fi
