# To create a new fcrepo / mariadb / solr server

1) Decrypt the secrets with `./bin/decrypt-secrets`

2) Create or edit the .env.$ENVIRONMENT file, changin the namespace to be unique for each network set you want to make.

3) Make sure the AWS profile in your ~/.aws/config and ~/.aws/credentials files match the AWS account you want to deploy to.

4) Run `./bin/tf workspace new $ENVIRONMENT`

5) Run `./bin/tf $ENVIRONMENT init`

6) Run `./bin/tf $ENVIRONMENT apply`
