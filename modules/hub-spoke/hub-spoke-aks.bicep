//USE this command to generate ARM JSON file: az bicep build --file hub-spoke-aks.bicep
// description('The name of the Managed Cluster resource.')
var clusterName = 'aks-01'

module hubSpokeDeploy '../../hub-and-spoke-playground/hub-01-bicep/hub-01.bicep' = {
  name: 'hub-spoke-deploy'
  params: {
      firewallTier: 'Premium'
      deployBastion: false
      deployGateway: false
      deployVmHub: false
      deployVm01: false
      deployVm02: false
      deployVm03: false
  }
}

module anyToAnyDeploy '../hub-and-spoke-playground/any-to-any-bicep/any-to-any.bicep' = {
  name: 'any-to-any-deploy'
  params: {
      firewallTier: hubSpokeDeploy.outputs.firewallTier
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
