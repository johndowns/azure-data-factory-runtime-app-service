# Azure Data Factory self-hosted integration runtime on App Service

## Step 1: Deploy a container registry

```azurecli
az group create \
  --name SHIRRegistry \
  --location australiaeast

az acr create \
  --resource-group SHIRRegistry \
  --name <YOUR-REGISTRY-NAME> \
  --sku Basic
```

Ensure that the admin user is enabled.

## Step 2: Build the container image

```azurecli
az acr build \
  --registry <YOUR-REGISTRY-NAME> \
  --image adf/shir:v3 \
  --platform Windows \
  https://github.com/johndowns/Azure-Data-Factory-Integration-Runtime-in-Windows-Container.git
```

## Step 3: Deploy the solution

```azurecli
az deployment group create \
  --resource-group SHIR \
  --template-file main.bicep \
  --parameters containerRegistryName=<YOUR-REGISTRY-NAME> containerRegistryUsername=<YOUR-REGISTRY-USERNAME> containerRegistryPassword=<YOUR-REGISTRY-PASSWORD> vmAdminPassword=<YOUR-VM-ADMIN-PASSWORD>
```
