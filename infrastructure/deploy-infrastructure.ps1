#declaring usefull variables for infrastructure deployment

#prefix for a unique identifier on resource names
$studentprefix = "GDMR"
#names for resources
$resourcegroupName = "fabmedical-rg"
$cosmosDBName = "fabmedical-cdb"
$webappName = "fabmedical-web"
$planName = "fabmedical-plan"
#defining regions (including it's region pair)
$location1 = "eastus2"
#easus2 region pair is centralus to ensure highest availability
$location2 = "centralus"

# Azure CLI commands
#creating resource group in location1 with given name (does not need to be unique)
az group create -l $location1 -n $resourcegroupName
#create a cosmosDB with 2 failover locations with a MongoDB api, backtick used for multi-line command
az cosmosDB create --name $cosmosDBName `
--resource-group $resourcegroupName `
--kind MongoDB `
--locations regionName=$location1 failoverPriority=0 isZoneRedundant=False `
--locations regionName=$location2 failoverPriority=1 isZoneRedundant=True `
--enable-multiple-write-locations
#create app service plan to set pricing tier to linux based plan
az appservice plan create --name $planName `
--resource-group $resourcegroupName `
--sku S1 `
--is-linux
#create the Web App with a single NGINX container
az webapp create --resource-group $resourcegroupName `
--plan $planName `
--name $webappName `
-i NGINX
