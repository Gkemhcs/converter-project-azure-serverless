param registryName string



resource container_registry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = { 
  name: registryName 
  
}

output acrName string= container_registry.name  
output acrLoginServer string=container_registry.properties.loginServer
