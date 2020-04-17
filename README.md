
# Nettsteder on Azure

## Multi-container using Docker Compose in Azure Web App for Containers
This custom image is based on the 'official image' of [WordPress from Docker Hub](https://hub.docker.com/_/wordpress/).

The following changes have been made in this custom image:
* [Explicitly uses WordPress 4.9.5, PHP 7.2 and Apache.]()
* [Adds PHP extension for Redis v4.0.2.]()
* [Adds Baltimore Cyber Trust Root Certificate file for SSL to MySQL.]()
* [Uses App Setting for MySQL SSL Certificate Authority certificate in WordPress wp-config.php.]()
* [Uses App Setting for Redis host name in WordPress wp-config.php.]()
* [Uses Redis Object Cache 1.3.8 WordPress plugin.]()

**NOTE: The settings above will be changed to**

* LEMP Stack
* PHP 7.3
* Latest WordPress version


Based on the "Create a multi-container (preview) app in Web App for Containers" [tutorial](https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-multi-container-app).

## Deploy

`az login` or go to https://shell.azure.com/

`git clone https://github.com/dss-web/nettsteder-docker`

`cd nettsteder-docker`

Update the following variables in [az-deploy.sh](az-deploy.sh)

```sh
LOCATION = "Norway East"
RESOURCEGROUP = ""
SERVICEPLAN = ""
APPNAME = ""
MYSQLSERVERNAME = ""
ADMINPASSWORD = ""
```

`sh az-deploy.sh`

When `az-deploy.sh` is done, open `http://<APPNAME>.azurewebsites.net` and finish the WordPress configuration.

## Clean up deployment

`az group delete --name <RESOURCEGROUP>`