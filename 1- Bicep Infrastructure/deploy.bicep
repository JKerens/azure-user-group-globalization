targetScope = 'subscription'

@allowed([
  'eastus'
  'canadaeast'
])
param region string = 'eastus'
@allowed([
  'Dev'
  'Staging'
  'Prod'
])
param environment string
param deploymentId string = newGuid()

// Load Constants File
var config = json(loadTextContent('../.shared/constants.json'))

var webappName = toLower('${environment}-${config.Company}-houston-talk')
var tags = {
  Contact: config.Contact
  Product: config.Product
  Environment: environment
}

// creates your resource group
// keep in mind az.resourceGroup() naming conflict here
resource resourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: webappName
  location: region
  tags:tags
}

module keyvault 'modules/keyvault.bicep' = {
  scope: resourceGroup
  name: 'keyvault-${deploymentId}'
  params: {
    keyvaultName: webappName
  }
}

resource keyvaultReference 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  scope: resourceGroup
  name: keyvault.outputs.keyvaultName
}

module webapp 'modules/web.bicep' = {
  name: 'webapp-${deploymentId}'
  scope: resourceGroup // Deployment scoped to the main ResourceGroup
  params: {
    webappName: webappName
    keyvaultName: keyvault.outputs.keyvaultName
    secretSauce: keyvaultReference.getSecret(keyvault.outputs.connectionStringName)
  }
}
