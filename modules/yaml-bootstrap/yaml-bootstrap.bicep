//https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-extensibility-kubernetes-provider
//PRIVATE clusters are not supported as of now: https://github.com/Azure/bicep-extensibility/issues/130

// description('The name of the Managed Cluster resource.')
param clusterName string = 'aks-01'
param location string = resourceGroup().location

module hubSpokeDeploy '../../hub-and-spoke-playground/hub-01-bicep/hub-01.bicep' = {
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
module aksDeploy '../default/default-aks.bicep' = {
    name: 'aks-deploy'
    params: {
        location: location
        clusterName: clusterName
        subnetID: hubSpokeDeploy.outputs.spoke01Vnet.properties.subnets[0].id
        availabilityZones: ['2']
        usePrivateApiServer: false
    }
}
module kubernetes './sample-aks.bicep' = {
  name: 'buildbicep-deploy'
  params: {
    kubeConfig: aksDeploy.outputs.kubeconfig
  }
}
