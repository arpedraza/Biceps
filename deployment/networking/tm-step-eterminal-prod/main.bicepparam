using './main.bicep'

param location = 'westeurope'
param environment = 'PROD'

param applicationName = 'step-eterminal'
param agwOriginalPIPName = 'pip-ep-agw-eterminal-prd-01'
param agwOriginalSubscriptionId = 'c71cfef2-700e-47e5-b810-e34898fd2249'
param agwOriginalResourceGroupName = 'rg-ep-step-prod-01'
param agwOriginalPriority = 2
param agwNewPIPName = 'pip-agw-edge-waf-prod-01'
param agwNewResourceGroupName = 'rg-mrg-waf-prod-01'
param agwNewPriority = 1
param healthProbePath = '/'
param healthProbeHostValue = 'ec524.euroports.com'
param diagnosticsSettings = [
   {
     name: 'all-logs-metrics'
     workspaceResourceId: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-tm-logs-prod-01/providers/Microsoft.OperationalInsights/workspaces/law-edge-tm-prod-01'
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
