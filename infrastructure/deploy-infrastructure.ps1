#declaring usefull variables for infrastructure deployment


#names for resources
$resourcegroupName = "fabmedical-rg"
$cosmosDBName = "fabmedical-cdb"
$webappName = "fabmedical-web"
$planName = "fabmedical-plan"
#defining regions (including it's region pair)
$location1 = "eastus2"
#easus2 region pair is centralus to ensure highest availability
$location2 = "centralus"
#app insight name for initializing app insights
$appInsights = "fabmedical-ai"

# Azure CLI commands
#creating resource group in location1 with given name (does not need to be unique)
az group create -l $location1 -n $resourcegroupName | ConvertFrom-Json
#create a cosmosDB with 2 failover locations with a MongoDB api, backtick used for multi-line command
az cosmosDB create --name $cosmosDBName `
--resource-group $resourcegroupName `
--kind MongoDB `
--locations regionName=$location1 failoverPriority=0 isZoneRedundant=False `
#--locations regionName=$location2 failoverPriority=1 isZoneRedundant=True `
#--enable-multiple-write-locations
#create app service plan to set pricing tier to linux based plan
az appservice plan create --name $planName `
--resource-group $resourcegroupName `
--sku S1 `
--is-linux

az webapp config appsettings set --settings DOCKER_REGISTRY_SERVER_URL="https://ghcr.io" --name $($webappName) --resource-group $($resourcegroupName)
az webapp config appsettings set --settings DOCKER_REGISTRY_SERVER_USERNAME="notapplicable" --name $($webappName) --resource-group $($resourcegroupName)
az webapp config appsettings set --settings DOCKER_REGISTRY_SERVER_PASSWORD="$($env:CR_PAT)" --name $($webappName) --resource-group $($resourcegroupName)

#create the Web App with a single NGINX container
az webapp create --resource-group $($resourcegroupName) `
--multicontainer-config-file ./docker-compose.yml `
--multicontainer-config-type COMPOSE `
--plan $($planName) `
--name $($webappName) `
-i NGINX

#commands for setting up application insights on azure
#az extension add --name application-insights
#$ai = az monitor app-insights component create --app $appInsights --location $location1 --kind web -g $resourcegroupName --application-type web --retention-time 120 | ConvertFrom-Json


#keeping commands in here for reference to update the website on azure
az webapp config container set `
--docker-registry-server-password $($env:CR_PAT) `
--docker-registry-server-url https://ghcr.io `
--docker-registry-server-user notapplicable `
--multicontainer-config-file ./docker-compose.yml `
--multicontainer-config-type COMPOSE `
--name $webappName `
--resource-group $resourcegroupName

az extension add --name application-insights
az monitor app-insights component create --app $appInsights --location $location1 --kind web -g $resourcegroupName --application-type web --retention-time 120