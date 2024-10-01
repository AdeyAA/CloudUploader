# CloudUploader CLI


CloudUplaoder is a simple command-line tool for uploading files to cloud storage using Bash. It allows users to specify the target directory, storage class, and provides a shareable pre-signed URL after successful uploads.


## Table of Contents


- [Features]
- [Installation]
- [Usage]
- [Options]
- [Prerequisites]
- [Configuration]
- [Error Handling]
- [Advanced Features]
- [Contributing]



---------


## Features

- Uplaod files to a cloud storage service (e.g., AWS s3).
	- Specify a target directory and storage class.
	- Upload with a progress bar (requires `pv`).
	- Encrypt the file before uploading.
	- Check if a file already exists in S3 and prompt for overwrite, skip, or rename.
	- Generate a pre-signed URL for sharing after a succesful upload (valid for 1 hour.
	- Error handling for invalid file paths, missing files, and upload failures.



## Installation

1. Clone the repository:
```bash
`git clone https://github.com/yourusername/CloudUploader.git`

2. Navigate into the project directory:

`cd CloudUploader`

3. Make the script executable:

`chmod +x clouduploader.sh`



## Usage

- To upload a file to cloud storage, run the following command:

`./clouduploader.sh /path/to/file.txt`

EXAMPLE:

`./clouduploader.sh -d uploads -s STANDARD /path/to/file.txt`

-This will upload `file.txt` to the `uploads` directory in the cloud storage with the STANDARD storage class.



-To encrypt the file before uploading, use the -e or --encrypt option, run the follwing command:
`./clouduploader.sh -e /path/to/file.txt


-The script shows a progress bar during file upload, as long as the `pv` command is installed.

-If the file already exists in the S3 bucket, the script will prompt you with the following choices:

	-Overwrite the file
	-Skip the uplaod
	-Rename the file



## Options

`-d, --directory`: Target directory in the cloud(default: `uploads`).

`-s, --storage`: Storage class (default: `STANDARD`).

`-h, --help`: Show help information.

`-e, --encrypt`: Encrypt your file before uploading


## Prerequisites

-Bash (running the script)
-Cloud CLI (e.g., AWS CLI for S3)
	-Install AWS CLI
	-Authenticate with AWS (e.g., `aws configure`)
-`pv` (Optional) : For displaying a progress bar during upload.
	-Install `pv`:
	```bash
	brew install pv
-`openssl` (Optional): Required for file encryption
	-Install `openssl`
	brew install openssl



## Configuration

-Before running the script you should configure your cloud provider credentials:
	-For AWS S3, run:
		`aws configure`
	-Set the `BUCKET_NAME` variable in the script to your personal bucket name.
		-`BUCKET_NAME="your-bucket-name"



## Error Handling 

-File Not Found: If the specified file path is invalid or does not exist, an error message will be displayed.

-Upload Failure: If the file upload fails due to network issues or authentication problems, the script will display the corresponding error message. 
