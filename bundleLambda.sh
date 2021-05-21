#!/bin/bash 

function bundle_lambda()
{
  # Clean up previous builds
  rm -rf package/ lambda.zip

  # Create a directory for dependencies
  mkdir package

  # Install libraries in the package directory
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    # Install libraries in the package directory
    # Install psycopg2 from linux locally - invalid ELF header
    # https://github.com/apex/apex/issues/884#issuecomment-413329199
    echo "Detected Mac OSX - Doing pip install in a linux docker container"
    docker run --rm -v $(pwd):/var/task lambci/lambda:build-python3.7 pip install --upgrade -r requirements.txt -t package/.
    cd package
  else
    cd package
    pip install --upgrade -r ../requirements.txt --target .
  fi

  # Create a ZIP archive
  zip -r9 ../lambda.zip .

  # Add your function code and version.txt to the archive.
  cd ..
  zip -g lambda.zip lambda_function.py
  zip -g lambda.zip version.txt

  # Remove the build dir
  rm -rf package
}

bundle_lambda