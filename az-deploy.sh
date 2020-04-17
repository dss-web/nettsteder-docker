#!/bin/sh

set -e  # stops your script if any simple command fails.

LOCATION = "Norway East"
RESOURCEGROUP = ""
SERVICEPLAN = ""
APPNAME = ""
MYSQLSERVERNAME = ""
ADMINPASSWORD = ""

if [ -z "$LOCATION" ] || [ -z "$RESOURCEGROUP" ] || [ -z "$SERVICEPLAN" ] || [ -z "$APPNAME" ] || [ -z "$MYSQLSERVERNAME" ] || [ -z "$ADMINPASSWORD" ]; then
  echo 'one or more variables are undefined'
  exit 1
fi


## Create

az group create --name $RESOURCEGROUP --location $LOCATION

az appservice plan create --name $SERVICEPLAN --resource-group $RESOURCEGROUP --sku S1 --is-linux

az webapp create --resource-group $RESOURCEGROUP --plan $SERVICEPLAN --name $APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml

az mysql server create --resource-group $RESOURCEGROUP --name $MYSQLSERVERNAME  --location $LOCATION --admin-user adminuser --admin-password $ADMINPASSWORD --sku-name B_Gen4_1 --version 5.7

az mysql server firewall-rule create --name allAzureIPs --server $MYSQLSERVERNAME --resource-group $RESOURCEGROUP --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

az mysql db create --resource-group $RESOURCEGROUP --server-name $MYSQLSERVERNAME --name wordpress

## Add Settings

az webapp config appsettings set --resource-group $RESOURCEGROUP --name $APPNAME --settings WORDPRESS_DB_HOST="$MYSQLSERVERNAME.mysql.database.azure.com" WORDPRESS_DB_USER="adminuser@$MYSQLSERVERNAME" WORDPRESS_DB_PASSWORD="$ADMINPASSWORD" WORDPRESS_DB_NAME="wordpress" MYSQL_SSL_CA="BaltimoreCyberTrustroot.crt.pem"

az webapp config container set --resource-group $RESOURCEGROUP --name $APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml

az webapp config appsettings set --resource-group $RESOURCEGROUP --name $APPNAME --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE

az webapp config container set --resource-group $RESOURCEGROUP --name $APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml

az webapp config appsettings set --resource-group $RESOURCEGROUP --name $APPNAME --settings WP_REDIS_HOST="redis"

az webapp config container set --resource-group $RESOURCEGROUP --name $APPNAME --multicontainer-config-type compose --multicontainer-config-file compose-wordpress.yml