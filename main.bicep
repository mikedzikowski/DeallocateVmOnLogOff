
targetScope = 'subscription'

@description('The location for the resources deployed in this solution.')
param location string = deployment().location

@description('Automation account name')
param aaAccount string = 'test-aa'

@description('The existing resource group for the resources deployed by this solution.')
param automationAccountRg string = 'testaa'

@description('Create a new automation account or use current one.')
param newAutomationAccount bool = true

@description('Subscription id of automation account.')
param automationAccountSubscriptionId string = subscription().subscriptionId

@description('Deployment name suffix.')
param deploymentNameSuffix string = utcNow()

@description('Action group name.')
param actionGroupName string = 'deallocateOnPoweroff-ag'

var roleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var automationAccountConnectionName = 'azureautomation'
var runbooksPwsh7 = [
  {
    name: 'Start-VmDeallocateOnShutdown'
    uri: 'https://raw.githubusercontent.com/mikedzikowski/DeallocateVmOnShutDown/main/runbooks/Start-VmDeallocateOnShutDown.ps1'
  }
]

var LocationShortNames = {
  australiacentral: 'ac'
  australiacentral2: 'ac2'
  australiaeast: 'ae'
  australiasoutheast: 'as'
  brazilsouth: 'bs2'
  brazilsoutheast: 'bs'
  canadacentral: 'cc'
  canadaeast: 'ce'
  centralindia: 'ci'
  centralus: 'cu'
  eastasia: 'ea'
  eastus: 'eu'
  eastus2: 'eu2'
  francecentral: 'fc'
  francesouth: 'fs'
  germanynorth: 'gn'
  germanywestcentral: 'gwc'
  japaneast: 'je'
  japanwest: 'jw'
  jioindiacentral: 'jic'
  jioindiawest: 'jiw'
  koreacentral: 'kc'
  koreasouth: 'ks'
  northcentralus: 'ncu'
  northeurope: 'ne'
  norwayeast: 'ne2'
  norwaywest: 'nw'
  southafricanorth: 'san'
  southafricawest: 'saw'
  southcentralus: 'scu'
  southeastasia: 'sa'
  southindia: 'si'
  swedencentral: 'sc'
  switzerlandnorth: 'sn'
  switzerlandwest: 'sw'
  uaecentral: 'uc'
  uaenorth: 'un'
  uksouth: 'us'
  ukwest: 'uw'
  usdodcentral: 'uc'
  usdodeast: 'ue'
  usgovarizona: 'az'
  usgoviowa: 'ia'
  usgovtexas: 'tx'
  usgovvirginia: 'va'
  westcentralus: 'wcu'
  westeurope: 'we'
  westindia: 'wi'
  westus: 'wu'
  westus2: 'wu2'
  westus3: 'wu3'
}


var subscriptionId = subscription().subscriptionId
var LocationShortName = LocationShortNames[location]
var NamingStandard = '${LocationShortName}'

var automationAccountNameVar = ((!empty(aaAccount)) ? [
  aaAccount
]: [
  replace('aa-${NamingStandard}', 'aa', uniqueString(NamingStandard))
])

var automationAccountNameValue = first(automationAccountNameVar)


module automationAccount 'modules/automationAccount.bicep' = {
  name: 'aa-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, automationAccountRg)
  params: {
    automationAccountName: automationAccountNameValue
    location: location
    pwsh7RunbookNames: runbooksPwsh7
    newAutomationAccount: newAutomationAccount
  }
}

module automationAccountConnection 'modules/automationAccountConnection.bicep' = {
  name: 'automationAccountConnection-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, automationAccountRg)
  params: {
    location: location
    connection_azureautomation_name: automationAccountConnectionName
    subscriptionId: subscriptionId
    displayName: automationAccountConnectionName
  }
  dependsOn: [
    automationAccount
  ]
}

module logicapp 'modules/logicapp.bicep' = {
  name: 'la-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, automationAccountRg)
  params: {

    automationAccountConnectionName : automationAccountConnectionName
    location : location
    subscriptionId : automationAccountSubscriptionId
    automationAccountName : automationAccountNameValue
    automationAccountResourceGroup : automationAccountRg
    automationAccountLocation : automationAccount.outputs.aaLocation
    automationAccountConnectId   : automationAccountConnection.outputs.automationConnectId
  }
}

module webhook 'modules/webhook.bicep'  = {
  name: 'wh-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, automationAccountRg)
  params:{
    subscriptionId: subscriptionId
    serviceUri: logicapp.outputs.logicAppGetUrl
    actionGroupName:  actionGroupName
    webhookReceiverName: 'URI'
    location: location
  }
}

module rbacPermissionAzureAutomationAccountRg 'modules/rbacPermissionsSubscriptionScope.bicep' = {
  name: 'rbac-automationAccountContributor-deployment-${deploymentNameSuffix}'
  params: {
    principalId: automationAccount.outputs.aaIdentityId
    scope: subscription().id
  }
  dependsOn: [
    automationAccount
    automationAccountConnection
  ]
}

module rbacPermissionAzureAutomationWconnector 'modules/rbacPermissions.bicep' = {
  name: 'rbac-aaConnectorWConn-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, automationAccountRg)
  params: {
    principalId: logicapp.outputs.imagePrincipalId
    roleId: roleId
    scope: 'resourceGroup().id'
  }
  dependsOn: [
    automationAccount
    automationAccountConnection
  ]
}

