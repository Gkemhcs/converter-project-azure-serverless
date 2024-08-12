param vnetName string 
param privateDnsZonePrefix string ='converter'
param zoneName string= '${privateDnsZonePrefix}.private.postgres.database.azure.com'

param serverName string='converter-db-server'

param dbName string= 'converter'

param location string  

param skuSizeGB int = 128
param sku string= 'Standard_B1ms'

param tier string= 'Burstable'

param subnetName string = 'subnet-psql'

param adminName string

@secure()
param adminPassword string 

resource private_dns_zone 'Microsoft.Network/privateDnsZones@2020-06-01'= {
  name: zoneName
  location: 'global'
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing ={
  name: vnetName
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${vnet.name}-link'
  parent: private_dns_zone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false  // Set to true if you want auto-registration of DNS records in the zone
  }
}

resource subnet_psql 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing={
  name:  subnetName
  parent: vnet
  }

resource postgresql_server 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01'= {
  name: serverName 
  location: location 
   
   
  sku: {
    name: sku
    tier:tier
  }
  properties:{
    version: '12'
    administratorLogin: adminName 
    administratorLoginPassword: adminPassword
     
    network:{
        
       delegatedSubnetResourceId: subnet_psql.id
       privateDnsZoneArmResourceId: private_dns_zone.id
    }
    highAvailability:{
      mode:'Disabled'
    }
    storage: {
      storageSizeGB: skuSizeGB
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    
     
  }
}

resource postgres_db 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01'= {
   name : dbName 
   parent: postgresql_server

    
}

output server_fqdn string =postgresql_server.properties.fullyQualifiedDomainName

output database_name string=postgres_db.name



