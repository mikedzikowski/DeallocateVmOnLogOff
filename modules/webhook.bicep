param scheduledqueryrules_Deallocate_name string = 'vmpoweredoff'
param subscriptionId string
param actionGroupName string
param webhookReceiverName string
param serviceUri string
param location string


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
        useAadAuth: false
      }
    ]
  }
}

resource scheduledqueryrules_Deallocate_name_resource 'microsoft.insights/scheduledqueryrules@2022-08-01-preview' = {
  name: scheduledqueryrules_Deallocate_name
  location: location
  tags: {
    Environment: 'Production'
  }
  properties: {
    displayName: scheduledqueryrules_Deallocate_name
    severity: 3
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      '/subscriptions/${subscriptionId}'
    ]
    targetResourceTypes: [
      'microsoft.compute/virtualmachines'
    ]
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'PT10M'
    criteria: {
      allOf: [
        {
          query: 'Event\n| where EventID == "1074"\n'
          timeAggregation: 'Count'
          dimensions: []
          resourceIdColumn: '_ResourceId'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: false
    actions: {
      actionGroups: [
        actionGroup.id
      ]
      customProperties: {
      }
    }
  }
}
