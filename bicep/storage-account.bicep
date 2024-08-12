
param subnetName string ='subnet-container-apps'
param accountName string= 'converterv2u3t'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: 'converter-vnet'
 }
resource storage_account 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: accountName
  
}

resource subnet_container_apps 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing= {
  name: subnetName
  parent: vnet
}


output subnet_id  string  =subnet_container_apps.id
output account_info string =storage_account.listKeys().keys[0].value
