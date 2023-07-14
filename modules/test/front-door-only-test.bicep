var clusterName = 'aks-01'
var nodeResourceGroup = 'cl01-aks-01-20230621T083306Z-rg'
var privateLinkServiceName = 'aks-pls'
var location = 'westeurope'

var frontDoorProfileName = 'aks-fd'
var frontDoorOriginGroupName = 'aks-origin-group'
var frontDoorOriginName = 'aks-origin'
var frontDoorRouteName = 'aks-route'
var frontDoorSkuName = 'Premium_AzureFrontDoor'
var frontDoorEndpointName = 'aks-afd-${uniqueString(resourceGroup().id)}'

resource privateLinkService 'Microsoft.Network/privateLinkServices@2022-11-01' existing = {
  name: privateLinkServiceName
  scope: resourceGroup(nodeResourceGroup)
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: frontDoorProfileName
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  name: frontDoorOriginGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'GET'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  name: frontDoorOriginName
  parent: frontDoorOriginGroup
  properties: {     
    hostName: privateLinkService.properties.alias
    httpPort: 80
    httpsPort: 443
    originHostHeader: privateLinkService.properties.alias
    priority: 1
    weight: 1000
    sharedPrivateLinkResource:{
        privateLinkLocation: location
        privateLink: {
           id: privateLinkService.id
        }
        requestMessage: clusterName
        status: 'Approved'
    }
  }
  dependsOn:[
    privateLinkService
  ]
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  name: frontDoorRouteName
  parent: frontDoorEndpoint
  dependsOn: [
    frontDoorOrigin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpOnly' //because the origin only exposes http
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorEndpointHostName string = frontDoorEndpoint.properties.hostName
