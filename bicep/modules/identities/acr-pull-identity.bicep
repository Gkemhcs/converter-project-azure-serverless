
param identityNameFrontend string = 'frontend' 
param identityNameAcrPull string =  'acrpull'

param identityNameBackend string= 'backend'


param acrName string 
param  storageAccountName string 


resource storage_account 'Microsoft.Storage/storageAccounts@2023-05-01' existing ={
  name: storageAccountName
}
resource azure_container_registry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: acrName
}


resource acr_image_pull 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing ={
  name: identityNameAcrPull
}

resource frontend 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing ={
  name: identityNameFrontend
}
resource backend 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing ={
  name: identityNameBackend
}


resource   storage_blob_contributor_role_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01'= {
  scope: storage_account
  name: guid(backend.id, storage_account.id, 'Storage Blob Data Contributor')
  properties:{
   principalId: backend.properties.principalId
   roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
      
 }
}

resource   acr_pull_role_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01'= {
  scope: azure_container_registry
  name: guid(acr_image_pull.id, azure_container_registry.id, 'ACR Pull')
  properties:{
   principalId: acr_image_pull.properties.principalId
   roleDefinitionId:  subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
      
 }
}


output frontendId string= frontend.id 

output acrpullId string = acr_image_pull.id 

output backendId string = backend.id 

output backendClientId string=backend.properties.clientId







