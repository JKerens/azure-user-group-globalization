param keyvaultName string
param keyvaultSkuName string = 'standard'
param keyvaultSkuFamily string = 'A'
param location string = resourceGroup().location

@secure()
param secretSauce string = newGuid()

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyvaultName
  location: location
  tags: resourceGroup().tags
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: subscription().tenantId
    accessPolicies: []
    sku: {
      name: keyvaultSkuName
      family: keyvaultSkuFamily
    }
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'mysecret'
  properties: {
    value: secretSauce
  }
}

// this avoids a bug if someone messes with the keyvault name at the resource level
output keyvaultName string = keyVault.name
output connectionStringName string = keyVaultSecret.name
