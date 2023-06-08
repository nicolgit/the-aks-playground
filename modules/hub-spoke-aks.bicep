// description('The name of the Managed Cluster resource.')
param clusterName string
param location string = resourceGroup().location

module hubSpokeDeploy '../hub-and-spoke-playground/hub-01-bicep/hub-01.bicep' = {
  name: 'hub-spoke-deploy'
  params: {
      location: location
      locationSpoke03: location
      firewallTier: 'Basic'
      deployBastion: false
      deployGateway: false
      deployVmHub: false
      deployVm01: false
      deployVm02: false
      deployVm03: false
  }
}
module aksDeploy 'default-aks.bicep' = {
    name: 'aks-deploy'
    params: {
        location: location
        clusterName: clusterName
        subnetID: hubSpokeDeploy.outputs.spoke01Vnet.properties.subnets[0].id
        availabilityZones: ['2']
        usePrivateApiServer: true
    }
}