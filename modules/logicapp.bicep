param workflows_deallocatevm_name string = 'deallocatevm'
param automationAccountConnectionName string
param location string
param subscriptionId string
param automationAccountName string
param automationAccountResourceGroup string
param automationAccountLocation string
param automationAccountConnectId   string

resource workflows_deallocatevm_name_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_deallocatevm_name
  location: location
  tags: {
    Department: 'IT'
    Environment: 'Non-Production'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {
          }
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
            }
          }
        }
      }
      actions: {
        For_each: {
          foreach: '@body(\'Parse_JSON\')?[\'data\']?[\'essentials\']?[\'configurationItems\']'
          actions: {
            Create_job: {
              runAfter: {
              }
              type: 'ApiConnection'
              inputs: {
                body: {
                  properties: {
                    parameters: {
                      VMNames: '@items(\'For_each\')'
                      environment: 'AzureUSGovernment'
                    }
                  }
                }
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'azureautomation\'][\'connectionId\']'
                  }
                }
                method: 'put'
                path: '/subscriptions/@{encodeURIComponent(\'${subscriptionId}\')}/resourceGroups/@{encodeURIComponent(\'${automationAccountResourceGroup}\')}/providers/Microsoft.Automation/automationAccounts/@{encodeURIComponent(\'${automationAccountName}\')}/jobs'
                queries: {
                  runbookName: 'Start-VmDeallocation'
                  wait: true
                  'x-ms-api-version': '2015-10-31'
                }
              }
            }
          }
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        Parse_JSON: {
          runAfter: {
          }
          type: 'ParseJson'
          inputs: {
            content: '@triggerBody()'
            schema: {
              properties: {
                data: {
                  properties: {
                    alertContext: {
                      properties: {
                        'Activity Log Event Description': {
                          type: 'string'
                        }
                        authorization: {
                          properties: {
                            action: {
                              type: 'string'
                            }
                            scope: {
                              type: 'string'
                            }
                          }
                          type: 'object'
                        }
                        caller: {
                          type: 'string'
                        }
                        channels: {
                          type: 'string'
                        }
                        claims: {
                          type: 'string'
                        }
                        correlationId: {
                          type: 'string'
                        }
                        eventDataId: {
                          type: 'string'
                        }
                        eventSource: {
                          type: 'string'
                        }
                        eventTimestamp: {
                          type: 'string'
                        }
                        level: {
                          type: 'string'
                        }
                        operationId: {
                          type: 'string'
                        }
                        operationName: {
                          type: 'string'
                        }
                        properties: {
                          properties: {
                            entity: {
                              type: 'string'
                            }
                            eventCategory: {
                              type: 'string'
                            }
                            hierarchy: {
                              type: 'string'
                            }
                            message: {
                              type: 'string'
                            }
                          }
                          type: 'object'
                        }
                        status: {
                          type: 'string'
                        }
                        subStatus: {
                          type: 'string'
                        }
                        submissionTimestamp: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    essentials: {
                      properties: {
                        alertContextVersion: {
                          type: 'string'
                        }
                        alertId: {
                          type: 'string'
                        }
                        alertRule: {
                          type: 'string'
                        }
                        alertTargetIDs: {
                          items: {
                            type: 'string'
                          }
                          type: 'array'
                        }
                        configurationItems: {
                          items: {
                            type: 'string'
                          }
                          type: 'array'
                        }
                        description: {
                          type: 'string'
                        }
                        essentialsVersion: {
                          type: 'string'
                        }
                        firedDateTime: {
                          type: 'string'
                        }
                        monitorCondition: {
                          type: 'string'
                        }
                        monitoringService: {
                          type: 'string'
                        }
                        originAlertId: {
                          type: 'string'
                        }
                        severity: {
                          type: 'string'
                        }
                        signalType: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                  }
                  type: 'object'
                }
                schemaId: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
      }
      outputs: {
      }
    }
    parameters: {
      '$connections': {
        value: {
          azureautomation: {
            connectionId: automationAccountConnectId
            connectionName: automationAccountConnectionName
            connectionProperties:{
            authentication: {
              type: 'ManagedServiceIdentity'
            }
          }
            id: concat('/subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/${automationAccountLocation}/managedApis/azureautomation')
          }
        }
      }
    }
  }
}
output 
