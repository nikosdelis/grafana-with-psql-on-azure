targetScope = 'subscription'

param location string
param name string
param env string

@minLength(12)
@secure()
param psqlAdminPassword string

@minLength(12)
@secure()
param grafanaAdminPassword string

@description('The object ID of the user or service principal that will have access to the secrets in the key vault')
@secure()
param kvSecretsOwnerId string

resource rgResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${name}-${env}'
  location: location
}

module keyVault 'modules/keyVault.bicep' = {
  name: 'kv'
  scope: rgResourceGroup
  params: {
    name: name
    psqlAdminPassword: psqlAdminPassword
    grafanaAdminPassword: grafanaAdminPassword
    kvSecretsOwnerId: kvSecretsOwnerId
  }
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVault.outputs.generatedName
  scope: rgResourceGroup
}

module psql 'modules/postgresql.bicep' = {
  name: 'psql'
  scope: rgResourceGroup
  dependsOn: [
    keyVault
  ]
  params: {
    name: name
    env: env
    psqlAdminPassword: kv.getSecret('PSQL-ADMIN-PASSWORD')
  }
}

module grafana 'modules/grafana.bicep' = {
  name: 'grafana'
  scope: rgResourceGroup
  dependsOn: [
    keyVault
    psql
  ]
  params: {
    name: name
    env: env
    kvName: keyVault.outputs.generatedName
    psqlHostname: '${psql.outputs.generatedName}.postgres.database.azure.com'
  }
}
