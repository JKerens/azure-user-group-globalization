targetScope = 'subscription'

param environment string
param region string = 'eastus'
param deploymentId string = newGuid()

// Load Constants File
var config = json(loadTextContent('../.shared/constants.json'))

var resourceGroupName = toLower('${environment}-${config.Company}-houston-talk')
var tagValue = 'I cant let you do that Dave...'
var tags = {
  Contact: config.Contact
  Product: config.Product
  Environment: environment
  James: tagValue
}

// creates your resource group
// keep in mind az.resourceGroup() naming conflict here
resource resourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroupName
  location: region
  tags: tags
}

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'required-james-tag'
  properties: {
    displayName: 'Required James Tag'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Tech Talk Definition'
    metadata: {
      version: '0.1.0'
      category: 'Tags'
    }
    policyRule: {
      if: {
        allOf: [
          {
            anyOf: [
              {
                field: 'tags[\'James\']'
                exists: false
              }
            ]
          }
        ]
      }
      then: {
        effect: 'modify'
        details: {
          // this is the contributor role
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: 'tags[\'James\']'
              // you have to right methods in ARM template syntax apparently
              // I think the works around a transpilor bug
              value: '[resourceGroup().tags[\'James\']]'
            }
          ]
        }
      }
    }
  }
}

resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'required-james-tag-policyset'
  properties: {
    displayName: 'Required James Tag Policyset'
    policyType: 'Custom'
    description: 'Tech Talk Inititive'
    metadata: {
      version: '0.1.0'
      category: 'Tags'
    }
    policyDefinitions: [
      {
        policyDefinitionId: policyDefinition.id // this just has to be globally unique and make sense to you
        policyDefinitionReferenceId: policyDefinition.id // ref the created definition above
      }
    ]
  }
}

module policyAssignment 'modules/assignment.bicep' = {
  scope: resourceGroup
  name: 'policy-assignment-${deploymentId}'
  params: {
    policySetDefinitionId: policySetDefinition.id
  }
}
