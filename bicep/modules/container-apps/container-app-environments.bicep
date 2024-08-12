param vnetName  string  

param subnetName string ='subnet-container-apps'

param containerAppEnvname string= 'converter-env-vnet'

param location string = 'centralindia'

param storageMountName string  = 'converter-mount'

param accountName string 

param fileShareName string 


resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: vnetName
}

resource storage_account 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: accountName
}

resource subnet_container_apps 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing= {
  name: subnetName
  parent: vnet
}


resource container_app_env 'Microsoft.App/managedEnvironments@2024-03-01'={
  name: containerAppEnvname
  location: location 
  properties:{ 
     vnetConfiguration:{
      infrastructureSubnetId: subnet_container_apps.id
      }
  }
}

var accountKey =storage_account.listKeys().keys[0].value

resource container_app_env_storage 'Microsoft.App/managedEnvironments/storages@2024-03-01' = {
     name:  storageMountName
     parent: container_app_env
     properties: {
      azureFile:{
         accessMode: 'ReadWrite' 
         accountKey: accountKey
         shareName: fileShareName 
         accountName: storage_account.name 
      }}

}

output shareName string= container_app_env_storage.properties.azureFile.shareName
output envName string=container_app_env.name 




