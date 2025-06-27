# Install Python Package

pip install boto3

# Create python virtual environment

python -m venv .venv

# .venv is the virtual environment name

# Activate the virtual environment

Get-ChildItem .\.venv\Scripts

# Should see Activate.ps1 file

. .\.venv\Scripts\Activate.ps1

# Again isntall boto3 insie virtual env

pip install boto3

# List boto3

pip freeze

# To deactivate:

deactivate

# Resources
https://boto3.amazonaws.com/v1/documentation/api/latest/guide/quickstart.html
https://github.com/boto/boto3/blob/develop/boto3/examples/s3.rst

# Now create Lambda function and Python script

Here we are creating a lamba function which would be triggered by the 

This Python script is designed to monitor AWS IAM access key age and send email reminders when keys are approaching expirationv

