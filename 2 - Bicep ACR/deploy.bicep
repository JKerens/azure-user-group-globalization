param environment string

var config = json(loadTextContent('../.shared/constants.json'))

var webappName = toLower('${config.Company}-houston-talk')

// Fill out the bicepconfig.json if this is getting a red squiggle
module webapp 'br/hcssTemplates:webapp:v1' = {
  name: 'my dev deployment'
  params: {
    application: webappName
    environment: environment
    secretSauce: 'secretSauce'
  }
}
