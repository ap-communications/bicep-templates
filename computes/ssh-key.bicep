@description('ssh key name')
param keyName string
@description('public key string')
param publicKey string
@description('tags for ssh-key')
param tags object = {}
@description('resource location')
param location string = resourceGroup().location

resource ssh 'Microsoft.Compute/sshPublicKeys@2020-12-01' = {
  name: keyName
  location: location
  properties: {
    publicKey: publicKey
  }
  tags: tags
}

output pubKey string = ssh.properties.publicKey
