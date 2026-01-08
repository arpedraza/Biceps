using './main.bicep'

param location = 'westeurope'
param environment = 'ACC'

param applicationName = 'integration'
param agwOriginalPIPName = 'pip-ep-agw-integration-acc-01'
param agwOriginalSubscriptionId = 'c2ae3152-6777-45b2-8c04-f4492ad08be4'
param agwOriginalResourceGroupName = 'rg-ep-edi-test-01'
param agwOriginalPriority = 2
param agwNewPIPName = 'pip-agw-edge-waf-nonprod-01'
param agwNewResourceGroupName = 'rg-mrg-waf-nonprod-01'
param agwNewPriority = 1
param healthProbePath = '/'
param healthProbeHostValue = 'integration-acc.euroports.com'
param diagnosticsSettings = [
   {
     name: 'all-logs-metrics'
     workspaceResourceId: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-tm-logs-nonprod-01/providers/Microsoft.OperationalInsights/workspaces/law-edge-tm-nonprod-01'
     logCategories: [
       {
         category: 'AllLogs'
       }
     ]
     metricCategories: [
      {
        category: 'AllMetrics'
      }
     ]
   }
 ]
