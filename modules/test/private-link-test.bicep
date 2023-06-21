var nodeResourceGroup = 'cl01-aks-01-20230621T083306Z-rg'
var privateLinkServiceName = 'aks-pls'
var location = 'westeurope'

resource privateLinkService 'Microsoft.Network/privateLinkServices@2022-11-01' existing = {
  name: privateLinkServiceName
  scope: resourceGroup(nodeResourceGroup)
}
var plAliasVar= privateLinkService.properties.alias
output plAlias string =plAliasVar
