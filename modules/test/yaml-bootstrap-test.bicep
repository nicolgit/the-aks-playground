param clusterName string
resource aks 'Microsoft.ContainerService/managedClusters@2023-03-01' existing = {
  name: clusterName
}
module kubernetes './sample-aks.bicep' = {
  name: 'buildbicep-deploy'
  params: {
    kubeConfig: aks.listClusterAdminCredential().kubeconfigs[0].value
     privateLoadBalancer: true
  }
}
