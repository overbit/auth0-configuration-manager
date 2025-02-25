#!bin/bash
set -euo pipefail

mode=$1
enviroment=${2:-"dev"}

cliConfigurations=.env.${enviroment}
tenant=$enviroment

if [ $? -ne 0 ]; then
  echo "Failed to call KMS encryption service: NoCredentialProviders"
  exit 1
fi

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

  if [[ "$mode" == "upload" ]]; then
    AUTH0_EXCLUDED='["emailProvider"]' npx a0deploy import  --format=directory --input_file configurations/${tenant}
  else
    AUTH0_EXCLUDED='["emailProvider"]' npx a0deploy export  --format=directory --output_folder configurations/${tenant}
  fi

else
    echo "$enviroment is not in the list. Available environments are: dev, staging, production"
    exit 1
fi


