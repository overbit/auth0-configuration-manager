# auth0-configuration-manager

Simple script to backup and restore auth0 configurations for tenant sync

Each tenant configuration contains the full spec. Since this might include secrets, all the clients configuration files are stored in git encrypted leveraging [SOPS: Secrets OPerationS](https://github.com/mozilla/sops).
This repo uses SOPS with AWS KMS keys stored in AWS services account.

## Prerequisite

To run locally the upload / download operation the following tools are needed:

- [SOPS](https://github.com/mozilla/sops). Available on homebrew `brew install sops`  
- A terminal session authenticated with AWS services account (this account contains the encryption key needed to encrypt/decrypt SOPS)
- Configure the local dot env files to avoid leaking secrets
  - [.env.dev.local]
  - [.env.production.local]

## Environments

The following auth environments are available:

- dev
- production

## Save auth0 configuration

Make all the necessary changes in Auth0 portal, get the AWS services credentials and then run:

```sh
npm i 

npm run download -- <environment>

# i.e. npm run download -- production
```

## Update auth0 configuration

Get the AWS services credentials and then run:

```sh
npm i 

npm run upload -- <environment>
# i.e. npm run upload -- production
```
