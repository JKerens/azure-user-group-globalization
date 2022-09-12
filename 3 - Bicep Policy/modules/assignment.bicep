param policySetDefinitionId string
param location string = resourceGroup().location

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'required-james-tag-policyassignment'
  location: location
  identity: {
    type: 'SystemAssigned' // creates the MSI account to handle add/updates
  }
  properties: {
    displayName: 'required-james-tag-policyassignment'
    description: 'Required James Tag Assignment'
    enforcementMode: 'Default'
    metadata: {
      version: '0.1.0'
    }
    policyDefinitionId: policySetDefinitionId
    nonComplianceMessages: [
      { 
        // ♥ write the policy offender a little love letter
        message: 'This is a JK non-compliance message'
      }
    ]
  }
}
