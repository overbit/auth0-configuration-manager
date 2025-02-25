#!bin/bash
set -euo pipefail

mode=$1
enviroment=${2:-"dev"}

cliConfigurations=.env.${enviroment}
tenant=$enviroment

SOPS_KMS_ARN="" # TODO

if [ $? -ne 0 ]; then
  echo "Failed to call KMS encryption service: NoCredentialProviders"
  exit 1
fi
function checkSopsReq {
  # exit with 1 if fail to run "aws kms describe-key --key-id $SOPS_KMS_ARN"
  check=$(aws kms describe-key --key-id $SOPS_KMS_ARN)
}

# function that use SOPS to encrypt all files in a folder
function encrypt_folder {
  checkSopsReq
  # exit with 1 if fail to run "aws kms describe-key --key-id $SOPS_KMS_ARN"
  check=$(aws kms describe-key --key-id $SOPS_KMS_ARN)
  folder=$1
  for file in $folder/*; do
    if [ -f "$file" ] && [ "${file: -4}" != ".enc" ] ; then
      echo "Encrypting $file"
      sops --encrypt --kms $SOPS_KMS_ARN $file > $file.enc
      rm $file
    fi
  done
}

# function that use SOPS to decrypt all files in a folder
function decrypt_folder {
  checkSopsReq
  folder=$1
  for file in $folder/*; do
    if [ -f "$file" ] && [[ $file =~ .*\.(enc$) ]] ; then
      echo "Decrypting $file"
      sops --decrypt --input-type json --output-type json $file > ${file%????}
    fi
  done
}


if [[ "$enviroment" =~ ^(dev)$ ]]; then
  cliConfigurations=.env.dev
  tenant=dev
fi

if [[ "$enviroment" =~ ^(staging)$ ]]; then
  cliConfigurations=.env.production
  tenant=production
fi

if [[ "$enviroment" =~ ^(dev|staging|production)$ ]]; then
  if [ -f "$cliConfigurations" ]; then
    export $(echo $(cat $cliConfigurations | sed 's/#.*//g'| xargs) | envsubst)
    export $(echo $(cat $cliConfigurations.local | sed 's/#.*//g'| xargs) | envsubst)
  fi
  decrypt_folder "configurations/${tenant}/connections"

  if [[ "$mode" == "upload" ]]; then
    AUTH0_EXCLUDED='["emailProvider"]' npx a0deploy import  --format=directory --input_file configurations/${tenant}
  else
    AUTH0_EXCLUDED='["emailProvider"]' npx a0deploy export  --format=directory --output_folder configurations/${tenant}
  fi
  encrypt_folder "configurations/${tenant}/connections"

else
    echo "$enviroment is not in the list. Available environments are: dev, staging, production"
    exit 1
fi


