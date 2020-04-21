#!/bin/sh

set -e  # stops your script if any simple command fails.

LOCATION="norwayeast" #List of available regions is 'centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus,southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest,brazilsouth,australiasoutheast,australiaeast,westindia,southindia,centralindia,canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth,francecentral,southafricanorth,uaenorth,australiacentral,switzerlandnorth,germanywestcentral,norwayeast'.
RESOURCEGROUP="minWPRG_001"
SERVICEPLAN="minWPRGsp_001"
APPNAME="minMultiSite"
ADMINPASSWORD="Hakkedun0me"
MYSQLSERVERNAME="minMultiSite"
MYSQLSKU="B_Gen5_2"
STORAGE="StorageV2"
STORAGESKU="Standard_LRS"

if [ -z "$LOCATION" ] || [ -z "$RESOURCEGROUP" ] || [ -z "$SERVICEPLAN" ] || [ -z "$APPNAME" ]|| [ -z "$ADMINPASSWORD" ] || [ -z "$MYSQLSERVERNAME" ] || [ -z "$MYSQLSKU" ]; then
  echo 'one or more variables are undefined'
  exit 1
fi


## Create

az group create --name $RESOURCEGROUP --location "$LOCATION"

az appservice plan create --name $SERVICEPLAN --resource-group $RESOURCEGROUP --sku S1 --is-linux

az webapp create --resource-group $RESOURCEGROUP --plan $SERVICEPLAN --name $APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml

az mysql server create --resource-group $RESOURCEGROUP --name $MYSQLSERVERNAME  --location "$LOCATION" --admin-user adminuser --admin-password $ADMINPASSWORD --sku-name $MYSQLSKU --version 5.7

az mysql server firewall-rule create --name allAzureIPs --server $MYSQLSERVERNAME --resource-group $RESOURCEGROUP --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

az mysql db create --resource-group $RESOURCEGROUP --server-name $MYSQLSERVERNAME --name wordpress

az storage account create --name "${APPNAME}_storage" --resource-group $RESOURCEGROUP --location "$LOCATION" --sku $STORAGESKU --kind $STORAGE

export storageAccountName="mystorageacct$RANDOM"

az storage account create \
    --resource-group $RESOURCEGROUP \
    --name "${APPNAME}_storage" \
    --location "$LOCATION" \
    --kind $STORAGE \
    --sku $STORAGESKU \
    --enable-large-file-share \
    --output none

export storageAccountKey=$(az storage account keys list \
    --resource-group $RESOURCEGROUP \
    --account-name "${APPNAME}_storage" \
    --query "[0].value" | tr -d '"')

shareName="myshare"

az storage share create \
    --account-name "${APPNAME}_storage" \
    --account-key $storageAccountKey \
    --name $shareName \
    --quota 1024 \
    --output none


az webapp config storage-account add --resource-group $RESOURCEGROUP --name "${APPNAME}_webstorage" --custom-id <custom_id> --storage-type AzureFiles --share-name "${APPNAME}_wordpress_file" --account-name "${APPNAME}_storage" --access-key "<access_key>" --mount-path <mount_path_directory>

## Add Settings

az webapp config appsettings set --resource-group $RESOURCEGROUP --name $APPNAME --settings WORDPRESS_DB_HOST="$MYSQLSERVERNAME.mysql.database.azure.com" WORDPRESS_DB_USER="adminuser@$MYSQLSERVERNAME" WORDPRESS_DB_PASSWORD="$ADMINPASSWORD" WORDPRESS_DB_NAME="wordpress" MYSQL_SSL_CA="BaltimoreCyberTrustroot.crt.pem"

az webapp config container set --resource-group $RESOURCEGROUP --name $APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml

az webapp config appsettings set --resource-group $RESOURCEGROUP --name $APPNAME --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE

az webapp config container set --resource-group $RESOURCEGROUP --name $APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml

az webapp config appsettings set --resource-group $RESOURCEGROUP --name $APPNAME --settings WP_REDIS_HOST="redis"

az webapp config container set --resource-group $RESOURCEGROUP --name $APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml