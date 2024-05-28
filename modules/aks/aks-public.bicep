param clusterName string = 'aks-01'
param nodeVMSize string = 'Standard_D2_v5'
param location string = resourceGroup().location
param virtualNetworkName string = 'vnet-01'

// description('The DNS prefix to use with hosted Kubernetes API server FQDN.') (optional)
param dnsPrefix string = 'aks01'

var nodePoolName = 'systempool'
var kubernetesVersion = '1.27.9'
param nodeResourceGroup string = '${dnsPrefix}-${clusterName}-${utcNow()}-rg'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.0.0/16'
      ]
    }
  }
}

resource akssubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'cluster-subnet'
  parent: vnet
  properties: {
    addressPrefix: '10.20.0.0/18'
  }
}

resource svcsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'services-subnet'
  parent: vnet
  properties: {
    addressPrefix: '10.20.64.0/18'
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-03-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: clusterName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: nodePoolName
        count: 1
        mode: 'System'
        vmSize: nodeVMSize
        osDiskSizeGB: 30
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        enableAutoScaling: false
        vnetSubnetID: akssubnet.id
      }
    ]
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    nodeResourceGroup: nodeResourceGroup
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
    }
  }
}
