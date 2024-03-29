//az deployment group create --resource-group <resource-group-name> --template-file default-aks.bicep --parameters @default-aks.parameters.json
//https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-extensibility-kubernetes-provider
//PRIVATE clusters are not supported as of now: https://github.com/Azure/bicep-extensibility/issues/130

var clusterName = 'aks-01'
var location = 'westeurope'
@description('username administrator for all VMs')
param username string = 'nicola'

@description('username administrator password for all VMs')
@secure()
param password string = 'password.123'


module hubSpokeDeploy '../../hub-and-spoke-playground/hub-01-bicep/hub-01.bicep' = {
  name: 'hub-spoke-deploy'
  params: {
    location: location
    locationSpoke03: location
    firewallTier: 'Premium'
    deployBastion: true
    deployGateway: false
    deployVmHub: true
    deployVm01: false
    deployVm02: false
    deployVm03: false
    username: username
    password: password
  }
}

module anyToAnyDeploy '../../hub-and-spoke-playground/any-to-any-bicep/any-to-any.bicep' = {
  name: 'any-to-any-deploy'
  params: {
    locationWE: location
    locationNE: location
    firewallTier: any(hubSpokeDeploy.outputs.firewallTier)
  }
}


module aksDeploy '../aks/aks.bicep' = {
  name: 'aks-deploy'
  params: {
    location: location
    clusterName: clusterName
    subnetID: hubSpokeDeploy.outputs.spoke01Vnet.properties.subnets[1].id
    availabilityZones: [ '3' ]
    usePrivateApiServer: false
  }
}

module kubernetes '../aks-vote-app/aks-vote-app.bicep' = {
  name: 'buildbicep-deploy'
  params: {
    kubeConfig: aksDeploy.outputs.kubeconfig
    privateLoadBalancer: true //this is needed in order to test DNAT rule from the firewall to the internal load balancer
  }
}
