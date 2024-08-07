#! /bin/bash 

az network vnet create --name converter-vnet  \
--address-prefixes  ['192.168.2.0/27','192.168.0.0/26','172.16.0.0/23']

az network vnet subnet create --name subnet-vm --vnet-name converter-vnet --address-prefixes "192.168.2.0/27"

az network vnet subnet create --name subnet-psql --vnet-name converter-vnet \
--address-prefixes "192.168.0.0/26" 

az network vnet subnet create --name subnet-container-env  --vnet-name converter-vnet \
--address-prefixes "172.16.0.0/23" \
--delegations  "Microsoft.App/environments"

export INFRASTRUCTURE_SUBNET_ID=$(az network vnet subnet show --name subnet-container-env --vnet-name converter-vnet --query "id" -o tsv | tr -d '[:space:]')
export INFRASTRUCTURE_RG_NAME="container-infra"

az containerapp env create --name converter-app-env --infrastructure-subnet-resource-id $INFRASTRUCTURE_SUBNET_ID  --infrastructure-resource-group $INFRASTRUCTURE_RG_NAME



assign permissions


az containerapp create -n frontend --environment converter-app-env --image convertergkem.azurecr.io/services/frontend --target-port 8080 --registry-identity  "/subscriptions/c13da0c2-b519-4248-a211-52095dd580d0/resourcegroups/converter-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/frontend" --user-assigned "/subscriptions/c13da0c2-b519-4248-a211-52095dd580d0/resourcegroups/converter-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/frontend"  --registry-server convertergkem.azurecr.io   --ingress external

az containerapp auth update --name frontend --unauthenticated-client-action AllowAnonymous





az containerapp create --name frontend --user-assigned "/subscriptions/c13da0c2-b519-4248-a211-52095dd580d0/resourcegroups/converter-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/frontend" --registry-identity "/subscriptions/c13da0c2-b519-4248-a211-52095dd580d0/resourcegroups/converter-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/frontend" --registry-server convertergkem.azurecr.io --image convertergkem.azurecr.io/services/frontend:v10 --ingress external --target-port 8080  --enable-dapr true  --dapr-app-port 8080 --dapr-app-id  frontend --secrets  client-secret="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"  --environment co
nverter-app-env


 az containerapp create --name pdf-to-docx-speech-converter --environment converter-app-env --registry-identity  "/subscriptions/c13da0c2-b519-4248-a211-52095dd580d0/resourcegroups/converter-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/frontend" --user-assigned  "/subscriptions/c13da0c2-b519-4248-a211-52095dd580d0/resourcegroups/converter-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/converter" --registry-server convertergkem.azurecr.io --image convertergkem.azurecr.io/services/pdf-to-docx-converter:v10 --ingress external --target-port 8082 --enable-dapr true --dapr-app-id pdf-to-doc-converter --dapr-app-port 8082 --env-vars CONTAINER_NAME=staging-container STORAGE_ACCOUNT_NAME=stagingstoragegkem,MANAGED_IDENTITY_CLIENT_ID=f2ae4200-3306-452b-83a3-e9cba797b7e2