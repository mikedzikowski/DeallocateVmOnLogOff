param activityLogAlerts_vmpoweredoff_name string = 'vmpoweredoff'
param subscriptionId string
param actionGroupName string
param webhookReceiverName string
param serviceUri string


resource actionGroup 'Microsoft.Insights/actionGroups@2019-06-01' = {
  name: actionGroupName
  location: 'global'
  properties: {
    groupShortName: 'webhook'
    enabled: true
    webhookReceivers: [
      {
        name: webhookReceiverName
        serviceUri: serviceUri
        useCommonAlertSchema: true
      }
    ]
  }
}


resource activityLogAlert 'microsoft.insights/activityLogAlerts@2020-10-01' = {
  name: activityLogAlerts_vmpoweredoff_name
  location: 'Global'
  tags: {
    Environment: 'Production'
  }
  properties: {
    scopes: [
      '/subscriptions/${subscriptionId}'
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'resourceType'
          equals: 'microsoft.compute/virtualmachines'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Compute/virtualMachines/powerOff/action'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroup.id
          webhookProperties: {
          }
        }
      ]
    }
    enabled: true
  }
}
