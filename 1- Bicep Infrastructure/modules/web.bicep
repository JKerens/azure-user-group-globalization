// webapp params
param webappName string
param skuName string = 'S1'
param skuCapacity int = 1
param location string = resourceGroup().location

// keyvault params
param keyvaultName string
@secure()
param secretSauce string

// webapp deployment
resource serverfarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: webappName
  location: location // Azure Region
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  tags: resourceGroup().tags
}

resource webapp'Microsoft.Web/sites@2021-03-01' = {
  name: webappName
  location: location
  tags: resourceGroup().tags
  properties: {
    serverFarmId: serverfarm.id
    siteConfig: {
      connectionStrings: [
        {
          name: 'secretSauce'
          connectionString: secretSauce
          type: 'SQLAzure'
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// If you need other secrets you can now assign an msi account dynamically
resource addIdentityScope 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01' = {
  name: any('${keyvaultName}/add') // based on github issues #905 https://github.com/Azure/bicep/issues/905#issuecomment-726889574
  properties: {
    accessPolicies: [
      {
        tenantId: webapp.identity.tenantId
        objectId: webapp.identity.principalId
        permissions: {
          keys: []
          secrets: [
            'get'
            'list'
          ]
          certificates: []
        }
      }
    ]
  }
}

// this avoids a bug if someone messes with the webapp name on line 17
output webappName string = webapp.name
