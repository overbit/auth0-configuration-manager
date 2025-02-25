# auth0-configuration-manager

Simple script to backup and restore auth0 configurations for tenant sync

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
