


param vnet_name string= 'converter-vnet'

param storageMountName string  = 'converter-mount'

param location string= 'centralindia'

param storage_account_base_name string= 'converter'

param storage_account_name_hash string =uniqueString(storage_account_base_name)

param storage_account_name string='converter${substring(storage_account_name_hash,0,5)}' 

param adminName string= 'postgres'

@secure()
param adminPassword string 


@description('The name of the blob container')
param blobContainerName string= 'converter-container'

@description('The name of the file share')
param filesharename string= 'converter-share'


param privateDnsPrefix string ='converter-zone'




param acrName string


param containerAppEnvname string=  'converter-apps-env-vnet'

param googleClientId string 

@secure()
param googleClientSecret string 




module  vnet_module 'modules/vnet/virtual-network.bicep'= {
name: 'vnet-module'

params: {
 vnet_name: vnet_name
 vnet_location: location 
}
}


module storage_account 'modules/storage/storage-account.bicep' ={ 
  name: 'storage-account'

  params:{
    storage_account_name: storage_account_name
    location : location 
    blobContainerName: blobContainerName
    filesharename:filesharename
    fileShareQuota: 256

  }
  

}

module postgresql_db 'modules/database/postgresql.bicep' = {
  name: 'postgres-server'

  params:{
    vnetName: vnet_name
    adminName:adminName
    adminPassword:adminPassword
    location: location
    privateDnsZonePrefix: privateDnsPrefix
    subnetName: vnet_module.outputs.subnet_psql_name
    
    }
    dependsOn: [vnet_module]

    
}




module container_app_env 'modules/container-apps/container-app-environments.bicep' = {
  name: 'converter-app-env'

  params: { 
    storageMountName: storageMountName
    vnetName: vnet_name
    accountName: storage_account.outputs.storageAccountName
    fileShareName: storage_account.outputs.fileshareName
    subnetName: vnet_module.outputs.subnet_apps_name
    containerAppEnvname: containerAppEnvname
    location: location  
  
  }
 

}


module identity_roles 'modules/identities/acr-pull-identity.bicep' = {
  name: 'identity-role'

  params: {
    acrName: acrName
    storageAccountName: storage_account.outputs.storageAccountName
     
  }
}

resource acr_converter 'Microsoft.ContainerRegistry/registries@2023-07-01' existing= {
  name: acrName
}

module frontend_app 'modules/container-apps/frontend-service.bicep' = {
  name: 'frontend-app'
 
  params: {
   acrPullIdentityId: identity_roles.outputs.acrpullId 
   frontendIdentityId: identity_roles.outputs.frontendId
   acrServer: acr_converter.properties.loginServer
   environmentName: container_app_env.outputs.envName
   postgresHost: postgresql_db.outputs.server_fqdn
   databaseName: postgresql_db.outputs.database_name
   adminName: adminName 
   adminPassword: adminPassword 
   azurefileStorageName: storageMountName
   googleClientId: googleClientId
   googleClientSecret: googleClientSecret
   appName: 'frontend' 
   location: location
  

 
  }

}



module pdf_to_docx_converter 'modules/container-apps/backend-service.bicep' = {
name: 'pdf-to-docx-converter'
params: {
      acrPullIdentityId: identity_roles.outputs.acrpullId 
      acrServer: acr_converter.properties.loginServer
      serviceType: 'pdf-to-docx-converter' 
      backendIdentityClientId: identity_roles.outputs.backendClientId 
      backendIdentityId: identity_roles.outputs.backendId 
      azurefileStorageName: storageMountName
      blobContainerName: storage_account.outputs.blobContainerName
      storageAccountName: storage_account.outputs.storageAccountName
      environmentName: container_app_env.outputs.envName
      appName: 'pdf-to-docx-converter'
      location: location 
      

}

}
module text_to_speech_converter 'modules/container-apps/backend-service.bicep' = {
  name: 'text-to-speech-converter'
  params: {
        acrPullIdentityId: identity_roles.outputs.acrpullId 
        acrServer: acr_converter.properties.loginServer
        serviceType: 'text-to-speech-converter' 
        backendIdentityClientId: identity_roles.outputs.backendClientId 
        backendIdentityId: identity_roles.outputs.backendId 
        azurefileStorageName: storageMountName
        blobContainerName: storage_account.outputs.blobContainerName
        storageAccountName: storage_account.outputs.storageAccountName
        environmentName: container_app_env.outputs.envName
        appName: 'text-to-speech-converter'
        location: location 
        
  
  }
  
  }
  module video_to_audio_converter 'modules/container-apps/backend-service.bicep' = {
    name: 'video-to-audio-converter'
    params: {
          acrPullIdentityId: identity_roles.outputs.acrpullId 
          acrServer: acr_converter.properties.loginServer
          serviceType: 'video-to-audio-converter' 
          backendIdentityClientId: identity_roles.outputs.backendClientId 
          backendIdentityId: identity_roles.outputs.backendId 
          azurefileStorageName: storageMountName
          blobContainerName: storage_account.outputs.blobContainerName
          storageAccountName: storage_account.outputs.storageAccountName
          environmentName: container_app_env.outputs.envName
          appName: 'video-to-audio-converter'
          location: location 
          
    
    }
    
    }
