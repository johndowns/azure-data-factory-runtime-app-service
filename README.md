# Azure Data Factory self-hosted integration runtime on App Service

## Deployment steps

```azurecli
az group create \
  --name SHIR \
  --location australiaeast

az deployment group create \
  --resource-group SHIR \
  --template-file main.bicep \
  --parameters vmAdminPassword=<YOUR-VM-ADMIN-PASSWORD>
```
