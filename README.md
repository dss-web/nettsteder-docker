
# Nettsteder on Azure

Based on https://github.com/Azure-Samples/multicontainerwordpress

## Multi-container using Docker Compose in Azure Web App for Containers
This custom image is based on the 'official image' of [WordPress from Docker Hub](https://hub.docker.com/_/wordpress/).

The following changes have been made in this custom image:
* [Explicitly uses WordPress 4.9.5, PHP 7.2 and Apache.]()
* [Adds PHP extension for Redis v4.0.2.]()
* [Adds Baltimore Cyber Trust Root Certificate file for SSL to MySQL.]()
* [Uses App Setting for MySQL SSL Certificate Authority certificate in WordPress wp-config.php.]()
* [Uses App Setting for Redis host name in WordPress wp-config.php.]()
* [Uses Redis Object Cache 1.3.8 WordPress plugin.]()

## TODO: The settings above will be changed to:

* LEMP Stack
* PHP 7.3
* Add [wp-cli](https://make.wordpress.org/cli/handbook/installing/) to `docker-entrypoint.sh`
* In `docker-entrypoint.sh`, use wp-cli to:
	* Install/Update latest WordPress version
	* Configure multisite
	* Update `wp-config.php`
* Add support for local docker deployment.
* Add Azure Front Door using `az-deploy.azcli`


## Deploy

`az login` or go to https://shell.azure.com/

`git clone https://github.com/dss-web/nettsteder-docker`

`cd nettsteder-docker`

Copy `.env-example` to `.env` and Update the following variables

```sh
LOCATION="norwayeast" #List of available regions is 'centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus,southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest,brazilsouth,australiasoutheast,australiaeast,westindia,southindia,centralindia,canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth,francecentral,southafricanorth,uaenorth,australiacentral,switzerlandnorth,germanywestcentral,norwayeast'.
RESOURCEGROUP=""
SERVICEPLAN=""
APPNAME=""
ADMINPASSWORD=""
MYSQLSERVERNAME=""
MYSQLSKU="B_Gen5_2"
STORAGE="StorageV2"
STORAGESKU="Standard_LRS"
storageAccountName="mystorageacct$RANDOM"
shareName="wpcontent"
```

`sh az-deploy.azcli`

When `az-deploy.azcli` is done, open `http://<APPNAME>.azurewebsites.net` and finish the WordPress configuration.

## Logs

If you run into issues using multiple containers, you can access the container logs by browsing to: `https://<APPNAME>.scm.azurewebsites.net/api/logs/docker`

## Clean up deployment

`az group delete --name <RESOURCEGROUP>`