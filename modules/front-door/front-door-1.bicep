//MAKE SURE to APPROVE privateLinks requested by FrontDoor, otherwise you will get a 502 error from FrontDoor
var clusterName = 'aks-01'
var clusterResourceGroup = 'cl01-${clusterName}-rg'
var privateLinkServiceName = 'pl-aks-01'
var location = 'westeurope'

module hubSpokeDeploy '../../hub-and-spoke-playground/hub-01-bicep/hub-01.bicep' = {
  name: 'hub-spoke-deploy'
  params: {
    location: location
    locationSpoke03: location
    firewallTier: 'Premium'
    deployBastion: false
    deployGateway: false
    deployVmHub: false
    deployVm01: false
    deployVm02: false
    deployVm03: false
  }
}

module aksDeploy '../aks/aks.bicep' = {
  name: 'aks-deploy'
  params: {
    location: location
    clusterName: clusterName
    nodeResourceGroup: clusterResourceGroup
    subnetID: hubSpokeDeploy.outputs.spoke01Vnet.properties.subnets[1].id
    availabilityZones: [ '3' ]
    usePrivateApiServer: false    
  }
}

module kubernetes '../aks-vote-app/aks-vote-app.bicep' = {
  name: 'buildbicep-deploy'
  params: {
    kubeConfig: aksDeploy.outputs.kubeconfig
    privateLinkServiceName: privateLinkServiceName
    privateLoadBalancer: true
  }
}
output clusterResourceGroupOut string = clusterResourceGroup
