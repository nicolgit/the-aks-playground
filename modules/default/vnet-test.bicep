param clusterName string
resource aks 'Microsoft.ContainerService/managedClusters@2023-03-01' existing = {
  name: clusterName
}


var subnetID = aks.properties.agentPoolProfiles[0].vnetSubnetID
var subnetArray = split(subnetID, '/')
var vnetName = subnetArray[length(subnetArray)-3]
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: vnetName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  dependsOn: [virtualNetwork]
  scope: resourceGroup()
  name: guid('aks-vnet')
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'//contributor
    principalId: aks.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output subnetID string = subnetID
output stringArray array = subnetArray
output vnetName string = vnetName
output vnetNameObj string = virtualNetwork.name
