param appName string= 'frontend'


param location string='centralindia'

param environmentName string 

param frontendIdentityId string 

param acrPullIdentityId string 
 
param googleClientId string 

param  acrServer string 

param frontendImage string='${acrServer}/services/frontend'

param volumeName string = 'azure-file-share'

param azurefileStorageName  string 

param postgresHost string 

param adminName string 

@secure()
param  adminPassword string 

param databaseName string 

@secure()
param googleClientSecret string 

resource converter_app_env 'Microsoft.App/managedEnvironments@2024-03-01' existing ={
  name: environmentName
}


resource frontend_app 'Microsoft.App/containerApps@2024-03-01' = { 
   name: appName 
   location: location 
   identity:  {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${frontendIdentityId}': {}
      '${acrPullIdentityId}' : {}
    }
   }
   properties: {
      managedEnvironmentId: converter_app_env.id
      configuration:{
         dapr: {
          enabled: true 
          appId: 'frontend'
          appPort: 8080 
          enableApiLogging: true 
        }
          registries: [
             {
               identity: acrPullIdentityId
               
               server: acrServer
              
             }
          ]

         
         ingress:{
              targetPort: 8080 
             
              external: true 
               
         }
          secrets: [{name:'google-client-secret',value:googleClientSecret}]
      }
       template:{
        containers: [
           {
             name: 'app-container'
             image:  frontendImage 
              
             env: [
              {name:'client-id',secretRef:'google-client-secret'}
              {name:'POSTGRES_DATABASE',value:databaseName}
              {name:'POSTGRES_HOST',value:postgresHost}
              {name:'POSTGRES_USER',value:adminName}
              {name:'POSTGRES_PASSWORD',value:adminPassword}
              {name: 'GOOGLE_CLIENT_ID',value: googleClientId}
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


resource google_auth_frontend 'Microsoft.App/containerApps/authConfigs@2024-03-01' = {
 name: 'current'   
 parent: frontend_app
 properties: {
   identityProviders: {
    google:{
      enabled:true
      registration: {
        clientId:googleClientId
        clientSecretSettingName:'google-client-secret'
      }

      validation: {
        allowedAudiences:[]
      }
    }
    
  }

  globalValidation: {
     unauthenticatedClientAction: 'AllowAnonymous'
  }
   platform: {
    enabled:true
  }
 }
  
}


output frontend_app_url string = frontend_app.properties.latestRevisionFqdn
