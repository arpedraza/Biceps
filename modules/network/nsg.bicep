// ============================================================================
// Network Security Group Module
// ============================================================================
// This module creates a Network Security Group with configurable rules
// Supports priority-based rules, source/destination filtering
// ============================================================================

@description('Name of the Network Security Group')
param nsgName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Array of security rules')
param securityRules array = []

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// Resource: Network Security Group
// ============================================================================
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: {
        protocol: rule.protocol
        sourcePortRange: contains(rule, 'sourcePortRange') ? rule.sourcePortRange : '*'
        destinationPortRange: contains(rule, 'destinationPortRange') ? rule.destinationPortRange : null
        destinationPortRanges: contains(rule, 'destinationPortRanges') ? rule.destinationPortRanges : null
        sourceAddressPrefix: contains(rule, 'sourceAddressPrefix') ? rule.sourceAddressPrefix : '*'
        sourceAddressPrefixes: contains(rule, 'sourceAddressPrefixes') ? rule.sourceAddressPrefixes : null
        destinationAddressPrefix: contains(rule, 'destinationAddressPrefix') ? rule.destinationAddressPrefix : '*'
        destinationAddressPrefixes: contains(rule, 'destinationAddressPrefixes') ? rule.destinationAddressPrefixes : null
        access: rule.access
        priority: rule.priority
        direction: rule.direction
        description: contains(rule, 'description') ? rule.description : ''
      }
    }]
  }
}

// ============================================================================
// Outputs
// ============================================================================
@description('Resource ID of the Network Security Group')
output nsgId string = nsg.id

@description('Name of the Network Security Group')
output nsgName string = nsg.name
