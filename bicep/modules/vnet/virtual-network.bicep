@description('NAME OF VIRTUAL NETWORK')
param vnet_name string

@description('LOCATION OF NETWORK IN WHICH WE WANT TO DEPLOY')
param vnet_location  string 

param address_prefixes array = ['172.16.0.0/23','192.168.1.0/27']

param apps_subnet object ={name:'subnet-container-apps',addressPrefix:'172.16.0.0/23'}

param psql_subnet object = {name:'subnet-psql',addressPrefix:'192.168.1.0/27'}

resource converter__vnet  'Microsoft.Network/virtualNetworks@2024-01-01'={
  name:  vnet_name
  location: vnet_location
  properties: {
     addressSpace:{addressPrefixes:address_prefixes}
  }
}
resource subnet_apps  'Microsoft.Network/virtualNetworks/subnets@2024-01-01'={
  name:  apps_subnet.name 
  parent: converter__vnet
  properties:{
    addressPrefix: apps_subnet.addressPrefix
  }
}



resource subnet_psql 'Microsoft.Network/virtualNetworks/subnets@2024-01-01'={
  name:  psql_subnet.name 
  parent: converter__vnet
  
  properties:{
    addressPrefix: psql_subnet.addressPrefix
    delegations: [ {
       name:  'Microsoft.DBforPostgreSQL/flexibleServers'
       properties: {
         serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
       }
    }]
  }

}

output converter_vnet_id string=converter__vnet.id

output subnet_apps_id string= subnet_apps.id

output subnet_apps_name string =subnet_apps.name

output subnet_psql_id string = subnet_psql.id

output subnet_psql_name string = subnet_psql.name



