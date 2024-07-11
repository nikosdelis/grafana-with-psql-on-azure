targetScope = 'resourceGroup'

param name string = 'grafana'
param env string
param kvName string
param psqlHostname string

resource asp 'Microsoft.Web/serverfarms@2021-03-01' = {
  location: resourceGroup().location
  name: 'asp-${name}-${env}'
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    zoneRedundant: false
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: 'app-${name}-${uniqueString(resourceGroup().id)}-${env}'
  location: resourceGroup().location
  kind: 'app,linux,container'
  properties: {
    serverFarmId: asp.id
    siteConfig: {      
      numberOfWorkers: 1
      linuxFxVersion: 'DOCKER|registry.hub.docker.com/grafana/grafana:latest'
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0      
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: ''
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://registry.hub.docker.com'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: ''
        }
        {
          name: 'GF_DATABASE_HOST'
          value: psqlHostname
        }
        {
          name: 'GF_DATABASE_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=PSQL-ADMIN-PASSWORD)'
        }
        {
          name: 'GF_DATABASE_SSL_MODE'
          value: 'require'
        }
        {
          name: 'GF_DATABASE_TYPE'
          value: 'postgres'
        }
        {
          name: 'GF_DATABASE_USER'
          value: 'postgres'
        }
        {
          name: 'GF_SECURITY_ADMIN_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=GRAFANA-ADMIN-PASSWORD)'
        }
        {
          name: 'GF_SERVER_ROOT_URL'
          value: 'https://app-${name}-${uniqueString(resourceGroup().id)}-${env}.azurewebsites.net'
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource acc 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: '${kvName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: webApp.identity.principalId        
        permissions: { secrets: [ 'get' ] }
        tenantId: subscription().tenantId    
      }
    ]
  }
}
