param location string
param automationAccountName string
param pwsh7RunbookNames array
param newAutomationAccount bool

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = if (newAutomationAccount) {
  name: automationAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
      identity: {}
    }
  }
}

resource aa 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: (newAutomationAccount) ? automationAccount.name : automationAccountName
}

resource pwsh7runbookDeployment 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = [for (runbook, i) in pwsh7RunbookNames: {
  name: runbook.name
  parent: aa
  location: location
  properties: {
    runbookType: 'PowerShell7'
    logProgress: true
    logVerbose: true
    publishContentLink: {
      uri: runbook.uri
      version: '1.0.0.0'
    }
  }
}]

output aaIdentityId string = newAutomationAccount ? automationAccount.identity.principalId : aa.identity.principalId
output aaLocation string = automationAccount.location
