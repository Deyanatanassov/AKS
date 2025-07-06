targetScope = 'subscription'

param resourceGroupName string = 'aks-overlay-rg'
param location string = 'eastus'
param clusterName string = 'aks-overlay'
param nodeCount int = 3
param nodeSize string = 'Standard_DS2_v2'
param podCidr string = '10.240.0.0/16'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${clusterName}-logs'
  location: location
  sku: {
    name: 'PerGB2018'
  }
  retentionInDays: 30
}

resource aks 'Microsoft.ContainerService/managedClusters@2023-10-01' = {
  name: clusterName
  location: location
  scope: rg
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: nodeCount
        vmSize: nodeSize
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      podCidr: podCidr
      loadBalancerSku: 'standard'
    }
    addonProfiles: {
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output resourceGroupName string = rg.name
output clusterName string = aks.name
