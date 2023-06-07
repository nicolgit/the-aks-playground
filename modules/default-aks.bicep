//az deployment group create --resource-group <resource-group-name> --template-file default-aks.bicep --parameters @default-aks.parameters.json
// description('The name of the Managed Cluster resource.')
param clusterName string
// Whether to deploy an API Server accessible ONLY from the vNET
param usePrivateApiServer bool = false
// description('Specifies the Azure location where the cluster should be created. Defaults to resource group location')
param location string = resourceGroup().location
//NETWORK
// description('The nodes' subnet ID. Make sure to provide the entire subnet ID and not subnet name')
param subnetID string
// Whether to use Overlay network mode (optional)
param useNetworkOverlay bool = false
//END NETWORK
//COMPUTE
// minValue(1), maxValue(50)
// description('The number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
param nodeCount int = 1
// description('The family and size of the Virtual Machine.') (optional)
param nodeVMSize string = 'Standard_D2s_v3'
param availabilityZones array = ['1','2','3']
//END COMPUTE
// description('The DNS prefix to use with hosted Kubernetes API server FQDN.') (optional)
param dnsPrefix string = 'cl01'
//OTHERS
// The nodes resource group name (optional)
param nodeResourceGroup string = '${dnsPrefix}-${clusterName}-rg'
param tags object = {
  environment: 'production'
  projectCode: 'xyz'
}

// The Kubernetes version (optional)
param kubeVersion string = ''
// The logAnalyticsWorkspace version (optional)
param logAnalyticsWorkspace string = ''
// Whether to use the AzureAD RBAC model instead of the native Kubernetes (optional)
param useAzureADRBAC bool = false
//END OTHERS
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
      enablePrivateCluster: usePrivateApiServer
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
#disable-next-line BCP321
          logAnalyticsWorkspaceResourceID: ((!empty(logAnalyticsWorkspace)) ? logAnalyticsWorkspace : null)
        }
        enabled: ((!empty(logAnalyticsWorkspace)) ? true : false)
      }
    }
  }
}

output aksid string = aks.id
output apiServerAddress string = aks.properties.privateFQDN
output aksnodesrg string = aks.properties.nodeResourceGroup