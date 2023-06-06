// parameters 
// description('The DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = 'cl01'

// description('The name of the Managed Cluster resource.')
param clusterName string = 'aks101'

// description('Specifies the Azure location where the cluster should be created. Defaults to resource group location')
param location string = resourceGroup().location

// minValue(1), maxValue(50)
// description('The number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
param nodeCount int = 1

// description('The family and size of the Virtual Machine.')
param nodeVMSize string = 'Standard_D2s_v3'

// description('The nodes' subnet ID. Make sure to provide the entire subnet ID and not subnet name')
param subnetID string

// The nodes resource group name
param nodeResourceGroup string = '${dnsPrefix}-${clusterName}-rg'

param tags object = {
  environment: 'production'
  projectCode: 'xyz'
}

// The Kubernetes version (optional)
param kubeVersion string

// The logAnalyticsWorkspace version (optional)
param logAnalyticsWorkspace string

// Whether to use the AzureAD RBAC model instead of the native Kubernetes (optional)
param useAzureADRBAC bool = false

// Whether to use Overlay network mode (optional)
param useNetworkOverlay bool = false

@allowed([
  '1'
  '2'
  '3'
])
param availabilityZones array

// vars
var nodePoolName = 'systempool'


// Create the Azure kubernetes service cluster
resource aks 'Microsoft.ContainerService/managedClusters@2023-03-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: ((!empty(kubeVersion)) ? kubeVersion : null)
    enableRBAC: useAzureADRBAC
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        availabilityZones: availabilityZones
        name: nodePoolName
        count: nodeCount
        mode: 'System'
        vmSize: nodeVMSize
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        enableAutoScaling: false
        vnetSubnetID: subnetID
      }

    ]
    apiServerAccessProfile:{
      enablePrivateCluster: true
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    nodeResourceGroup: nodeResourceGroup
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
      networkPluginMode: (useNetworkOverlay ? 'overlay' : null)
    }
    addonProfiles:{
      omsagent:{
        config:{
          logAnalyticsWorkspaceResourceID: ((!empty(logAnalyticsWorkspace)) ? logAnalyticsWorkspace : '')
        }
        enabled: ((!empty(logAnalyticsWorkspace)) ? true : false)
      }
    }
  }
}

output aksid string = aks.id
output apiServerAddress string = aks.properties.privateFQDN
output aksnodesrg string = aks.properties.nodeResourceGroup