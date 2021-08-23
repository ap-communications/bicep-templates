@description('Name of the alert')
@minLength(1)
param alertName string

@description('Description of alert')
param alertDescription string = 'alert of node disk usage percentage'

@description('Severity of alert {0,1,2,3,4}')
@allowed([
  0
  1
  2
  3
  4
])
param alertSeverity int = 3

@description('kubernetes cluster name')
param aksClusterName string
@description('Full Resource ID of the kubernetes cluster emitting the metric that will be used for the comparison. For example /subscriptions/00000000-0000-0000-0000-0000-00000000/resourceGroups/ResourceGroupName/providers/Microsoft.ContainerService/managedClusters/cluster-xyz')
@minLength(1)
param clusterResourceId string

@description('Operator comparing the current value with the threshold value.')
@allowed([
  'Equals'
  'NotEquals'
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param operator string = 'LessThan'

@description('The threshold value at which the alert is activated.')
@minValue(0)
@maxValue(100)
param threshold int = 80

@description('The ID of the action group that is triggered when the alert is activated or deactivated')
param actionGroupId string = ''

@description('tags for this alert')
param tags object = {}


module metric 'metric-alert.bicep' = {
  name: 'apply-pod-eady-for-${aksClusterName}'
  params: {
    alertName: alertName
    alertDescription: alertDescription
    alertSeverity: alertSeverity
    clusterResourceId: clusterResourceId
    operator: operator
    threshold: threshold
    actionGroupId: actionGroupId
    timeAggregation: 'Average'
    metricName: 'PodReadyPercentage'
    metricNamespace: 'pods'
    dimensions: [
      {
        name: 'kubernetes namespace'
        operator: 'Include'
        values: [
            '*'
        ]
      }
      {
          name: 'controllerName'
          'operator': 'Include'
          values: [
              '*'
          ]
      }      
    ]
    tags: tags
  }
}
