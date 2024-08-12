

param storage_account_name string 

param location string= 'centralindia'

@description('The name of the blob container')
param blobContainerName string

@description('The name of the file share')
param filesharename string


param fileShareQuota int = 100
param storageSku string=  'Standard_GRS'
resource converter_storage_account 'Microsoft.Storage/storageAccounts@2023-05-01' ={
name: storage_account_name
kind:'StorageV2'
location: location 
sku: {
name: storageSku
} 
properties: {

  accessTier: 'Hot'
}
}


resource blob_service 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01'= {
  name: 'default'
  parent: converter_storage_account
  properties: {
    isVersioningEnabled:true
  }
}




resource blob_container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' ={
  name: blobContainerName
  parent : blob_service
}

resource file_share_service  'Microsoft.Storage/storageAccounts/fileServices@2023-05-01'= {
  name: 'default'
  parent: converter_storage_account
 
}

resource file_share 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01'= {

  name: filesharename
  parent: file_share_service
  properties:{
    accessTier: 'TransactionOptimized'
    shareQuota: fileShareQuota
  }
}




output storageAccountName  string =converter_storage_account.name 

output blobContainerName string= blob_container.name 

output fileshareName string=file_share.name


