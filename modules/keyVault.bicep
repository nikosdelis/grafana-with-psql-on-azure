targetScope = 'resourceGroup'

param name string = 'grafana'

@secure()
param psqlAdminPassword string

@secure()
param grafanaAdminPassword string

@secure()
param kvSecretsOwnerId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${name}-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  properties: {
    enablePurgeProtection: true
    sku: {
      name: 'standard'
      family: 'A'
    }
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        objectId: kvSecretsOwnerId
        permissions: { secrets: [ 'list', 'get' ] }
        tenantId: subscription().tenantId
      }
    ]
  }
}

resource psqlAdminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: 'PSQL-ADMIN-PASSWORD'
  parent: keyVault
  properties: {
    value: psqlAdminPassword
  }
}

resource grafanaAdminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: 'GRAFANA-ADMIN-PASSWORD'
  parent: keyVault
  properties: {
    value: grafanaAdminPassword
  }
}

output generatedName string = keyVault.name
