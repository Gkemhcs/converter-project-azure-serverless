param appName string= 'frontend'

param serviceType string 
param location string='centralindia'

param environmentName string 

param backendIdentityId string 
param backendIdentityClientId string 

param acrPullIdentityId string 
 


param  acrServer string 

param backendImage string='${acrServer}/services/${serviceType}'

param volumeName string = 'azure-file-share'

param azurefileStorageName  string 

param storageAccountName string 
param blobContainerName string 

resource converter_app_env 'Microsoft.App/managedEnvironments@2024-03-01' existing ={
  name: environmentName
}

resource backend_app 'Microsoft.App/containerApps@2024-03-01' = { 
   name: appName 
   location: location 
   identity:  {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${backendIdentityId}': {}
      '${acrPullIdentityId}': {}
    }
   }
   properties: {
      managedEnvironmentId: converter_app_env.id
      configuration:{
         dapr: {
          enabled: true 
          appId: serviceType
          appPort: 8080 
          enableApiLogging: true 
        }
          registries: [
             {
               identity: acrPullIdentityId
               passwordSecretRef: ''
               server: acrServer
               username: ''
             }
          ]

         
         ingress:{
            targetPort: 8080 
             
              external: false
               
         }
          
      }
       template:{
        containers: [
           {
             name: 'app-container'
             image:  backendImage
             env: [
              {name:'MANAGED_IDENTITY_CLIENT_ID',value:backendIdentityClientId} 
              {name:'CONTAINER_NAME',value: blobContainerName}
              {name:'STORAGE_ACCOUNT_NAME',value:storageAccountName}

             ]
             volumeMounts: [
              {
                mountPath: '/mnt/azure'
                volumeName:  volumeName
            }
             ]
           }
        ]
        scale:{ 
          minReplicas: 1 
          maxReplicas: 5 
        }
        
         volumes: [
          {
            name:volumeName 
            storageName: azurefileStorageName 
            storageType: 'AzureFile'  
              
          }
         ]
       }
        
   }
    
}





