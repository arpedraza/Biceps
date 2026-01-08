param applicationGateways_agw_step_eterminal_api_prd_westeu_01_name string = 'agw-step-eterminal-api-prd-westeu-01'
param virtualNetworks_vnet_ep_shared_westeu_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-network-prod-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-westeu-01'
param publicIPAddresses_pip_ep_agw_eterminal_api_prd_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-step-prod-01/providers/Microsoft.Network/publicIPAddresses/pip-ep-agw-eterminal-api-prd-01'

resource applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_agw_step_eterminal_api_prd_westeu_01_name
  location: 'westeurope'
  properties: {
    sku: {
      name: 'Standard_Small'
      tier: 'Standard'
      family: 'Generation_1'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_westeu_01_externalid}/subnets/snet-ep-shared-applicationgateway-westeu-01'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'certwildcard'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/sslCertificates/certwildcard'
        properties: {}
      }
    ]
    authenticationCertificates: [
      {
        name: 'StandardHttps3120315c-1e8a-48ca-9cab-fefb7fa35171'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/authenticationCertificates/StandardHttps3120315c-1e8a-48ca-9cab-fefb7fa35171'
        properties: {
          data: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlIc2pDQ0JwcWdBd0lCQWdJUURvb09MQWdUaW9wbldCNkY5c01KVFRBTkJna3Foa2lHOXcwQkFRc0ZBREJQDQpNUXN3Q1FZRFZRUUdFd0pWVXpFVk1CTUdBMVVFQ2hNTVJHbG5hVU5sY25RZ1NXNWpNU2t3SndZRFZRUURFeUJFDQphV2RwUTJWeWRDQlVURk1nVWxOQklGTklRVEkxTmlBeU1ESXdJRU5CTVRBZUZ3MHlNVEV3TVRnd01EQXdNREJhDQpGdzB5TWpFd01UZ3lNelU1TlRsYU1GWXhDekFKQmdOVkJBWVRBa0pGTVJBd0RnWURWUVFIRXdkQ1pYWmxjbVZ1DQpNUnN3R1FZRFZRUUtFeEpGZFhKdmNHOXlkSE1nUjNKdmRYQWdRbFl4R0RBV0JnTlZCQU1NRHlvdVpYVnliM0J2DQpjblJ6TG1OdmJUQ0NBaUl3RFFZSktvWklodmNOQVFFQkJRQURnZ0lQQURDQ0Fnb0NnZ0lCQUxUYTA5cURva2RGDQpCdklaTnFaOE9ieDlDT1llWmRtRktpSlIyV2hJRDErYWhKZWppN2NDd29mRjB1RnlQQ1Q1WGY1V1pMVlZKbGFmDQpYbnJ2UnNYT1YvbjdpdnVQaUtwdWxsNkhwR1BGUEw3Nk9rUEE0ZnY3RHIxck1jWGdmL0VIRjlCN0dMb21GODdxDQo1UkRoa2RLcFhONU5TaGZSZTFGdnJwSUFwWHhtYndHWXRSUzJsYm8zNDhzRjlWV1ljQlNWVElXeStQRW9zNlJxDQo4dHJHN0NuRTA2RnhPMS9zd3NtVzdadGhwVkljbnc2Tkxsb1ZxbGhQaHZiSjV1L3FJazFjWVlFMTcwZktpcmVUDQoxVlQwclJhdExYS1JVMDlYVVlGYjM1V2w3MVJrb1B4cWJmVmtDam1GbDQralVpcE5jZFEwc1k4MjUybHAvVXZpDQpKSHVYNWhyRzRRRFZjeEw2dFB2QTRvZS9qeW5MaDM3VFRmRDBjSk1xQkdndkl2TFFtOVhITzV0SGMvWW00My8wDQpjK0NINHRGaGtYa0FUOE94SSt1TnVGdFQ0L1F3UlkyeHVlK2JkNkRyYzNpN3FaZnNML3NJbkdsd0IxaVZibDFQDQprZzM2RTJNRzlEVHpGWHBCSjY5dFAwMU5tRytReGxVK3BPcTkxWVF2NXc2LzhVNTdndDBkQnd1WGl3dXF6eGl3DQpqYnVocmdtNGVhM1FJZnJkRkhobTNYVG1IdzRNbDllLzJSdVhjZjRNT2RYbFhEZWlKdU5Lc2NuYjlPaHp2NUh0DQpNenRVS0tyb0Nzd1V2enZKOXdicEVidnNRSzQxV3I5bzlMZFRkckMyY2VESFVpUUljNFVITnM5OS9LVDYxOWZyDQphdEVSOTFGeTlDRmFXMTV2U3UxVFpudzUxNlBmTjB3M0FnTUJBQUdqZ2dPQk1JSURmVEFmQmdOVkhTTUVHREFXDQpnQlMzYTZMcXFLcUVqSG5xdE5vUG1MTEZsWGE1OURBZEJnTlZIUTRFRmdRVVdGbHRZcjlTVDg5YlJQYnJQbjFNDQpNNERkV1RJd0tRWURWUjBSQkNJd0lJSVBLaTVsZFhKdmNHOXlkSE11WTI5dGdnMWxkWEp2Y0c5eWRITXVZMjl0DQpNQTRHQTFVZER3RUIvd1FFQXdJRm9EQWRCZ05WSFNVRUZqQVVCZ2dyQmdFRkJRY0RBUVlJS3dZQkJRVUhBd0l3DQpnWThHQTFVZEh3U0JoekNCaERCQW9ENmdQSVk2YUhSMGNEb3ZMMk55YkRNdVpHbG5hV05sY25RdVkyOXRMMFJwDQpaMmxEWlhKMFZFeFRVbE5CVTBoQk1qVTJNakF5TUVOQk1TMDBMbU55YkRCQW9ENmdQSVk2YUhSMGNEb3ZMMk55DQpiRFF1WkdsbmFXTmxjblF1WTI5dEwwUnBaMmxEWlhKMFZFeFRVbE5CVTBoQk1qVTJNakF5TUVOQk1TMDBMbU55DQpiREErQmdOVkhTQUVOekExTURNR0JtZUJEQUVDQWpBcE1DY0dDQ3NHQVFVRkJ3SUJGaHRvZEhSd09pOHZkM2QzDQpMbVJwWjJsalpYSjBMbU52YlM5RFVGTXdmd1lJS3dZQkJRVUhBUUVFY3pCeE1DUUdDQ3NHQVFVRkJ6QUJoaGhvDQpkSFJ3T2k4dmIyTnpjQzVrYVdkcFkyVnlkQzVqYjIwd1NRWUlLd1lCQlFVSE1BS0dQV2gwZEhBNkx5OWpZV05sDQpjblJ6TG1ScFoybGpaWEowTG1OdmJTOUVhV2RwUTJWeWRGUk1VMUpUUVZOSVFUSTFOakl3TWpCRFFURXRNUzVqDQpjblF3REFZRFZSMFRBUUgvQkFJd0FEQ0NBWDRHQ2lzR0FRUUIxbmtDQkFJRWdnRnVCSUlCYWdGb0FIWUFScVZWDQo2M1g2a1NBd3RhS0phZlR6ZlJFc1FYUysvVW00aGF2eS9IRCtiVWNBQUFGOGsyTVBGZ0FBQkFNQVJ6QkZBaUE4DQpYTjlFb3UrNjlCVFpicHQzU2dVN25JQ3BkVTc2QlFXL0lKaEZWamh1Z3dJaEFPeFk0WGUrWmF4YjFuYlhqU0lIDQpiZDJNTE0zaUEycytycEQ3ck9VcUs5QUtBSFVBVWFPdzlmMEJlWnhXYmJnM2VJOE1wSHJNR3lmTDk1NklRcG9ODQovdFNMQmVVQUFBRjhrMk1QU1FBQUJBTUFSakJFQWlBeHZDM3hPZ3JNZ1hmL0FOd0h3NytyWlR4TXZPVENJY080DQppbEFnd01YNS9RSWdlY256UWlxc3dNYlFCQXIzNEVQdnB3ZlFpMjRSZDlSc0ZTZ2Y2NXFPUUdVQWR3QkJ5TXF4DQozeUpHU2hER29Ub0pRb2RlVGpHTEd3UHI2MHZIYVBDUVlwWUc5Z0FBQVh5VFl3N01BQUFFQXdCSU1FWUNJUURMDQpxRVllYW1Ca3RzVjd0b1cxOEJJbmNtZkZFUEJFTUFZTlBLQVl4YVhxd0FJaEFMdHBUUi92aUc3YmZ0ZmpBZndDDQo5cS9tYW9ZSUtja2lCbG9GZVd3dDRZME1NQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUFVYU9IdVdRTyt4K3NMDQpLMjJseldlSEMvclVsa3kxR2tPQXFUNldPQUNGNk92YnNieW51RGRSdUFPbngwOVlCQm5ZZklRb2xnRllhWjNIDQpSQkxBWkcxYjlnUlpPQkVQampNU2dNNWNjQ2V0b1pza2FSVXRlT0NFSXp2TW1XaXpyc1RrR1Q1TG1oNXo5K0xXDQpiUFFidkdMajd3MmFKbzd1S2ltbXI0a2M4N3FkM3FJZFZpVFFuWGNpdmtxSjUxeUttdmtwR1p2K3FiOUY1cTE1DQpTSmRkQmh3QlN2S2d6Q1BiUlpqcUd4RG44a0JnK3ZqYy9wK3Nra0VvZFFSRkwxWDFhM3NoV2VBaS95eUdUc1pMDQo5OEV0cWhTODZhYVhqbVRzdnpwcU5LZjVKckhpREVQNnFqeTE5WUZIQllncUJGak9mVTdtT3lJZmFBUFd1Y2IyDQpjM1IzTXdXVA0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ0K'
        }
      }
      {
        name: 'EuroportsCertitifcate20232024'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/authenticationCertificates/EuroportsCertitifcate20232024'
        properties: {
          data: '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'
        }
      }
      {
        name: 'EuroportsWildcard2024-2025'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/authenticationCertificates/EuroportsWildcard2024-2025'
        properties: {
          data: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlIMVRDQ0JyMmdBd0lCQWdJUUJDNDhnS2RpYWRaa3ZPT1JNaUM1VmpBTkJna3Foa2lHOXcwQkFRc0ZBREJaDQpNUXN3Q1FZRFZRUUdFd0pWVXpFVk1CTUdBMVVFQ2hNTVJHbG5hVU5sY25RZ1NXNWpNVE13TVFZRFZRUURFeXBFDQphV2RwUTJWeWRDQkhiRzlpWVd3Z1J6SWdWRXhUSUZKVFFTQlRTRUV5TlRZZ01qQXlNQ0JEUVRFd0hoY05NalF4DQpNREF6TURBd01EQXdXaGNOTWpVeE1ESXhNak0xT1RVNVdqQldNUXN3Q1FZRFZRUUdFd0pDUlRFUU1BNEdBMVVFDQpCeE1IUW1WMlpYSmxiakViTUJrR0ExVUVDaE1TUlhWeWIzQnZjblJ6SUVkeWIzVndJRUpXTVJnd0ZnWURWUVFEDQpEQThxTG1WMWNtOXdiM0owY3k1amIyMHdnZ0lpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElDRHdBd2dnSUtBb0lDDQpBUURtWjd4R284L0lnQ1l3RUY3dCtyKzc2MGJ4UUY0RUIvQXNjVWJpSTAxWmU5YXF0RFRxUmRnTGhiL2tXZS9zDQpITXYwY1BKd3hNZXVna2dDbU9oSm9JZnJlRDBKMmNsTnN2MStkeWVrSDFraEo0YWx2dHBOcHo0Q1M0L3Frak5xDQpSa0YzKytYTFVNZTJFbVFHRWtQTE9tOUd2WTI2czB6cUpLaUNXL05mdi8xWGwzZUNWVjJaTCtDc3FXNlVTbFM1DQplUk4rdW4xUUFCdHJHL0ZoT0V4QzI4c09UQk92Y1k2czNkTkpNcHZyMGRIaHE0YzNGaFdWcS80cmdkTEpvSnJLDQpabjNqV0huZFFBOGFMdEpxcXZGbkVoelZZVDlLZ3BMQ1JlWld5YStvSk1EWkZqNUhBZktoKy80bnBBRUNXZW43DQpZMXFubHJ0U1ZTQ2RiZzBDdGhGOHU2VjJWZkpibStrTUUya2JPSXdZY25SYXZpWVY5QXEwcXdNVmZJNUYrNmdGDQp2dko4UTVEWWpiZnRHTzUxQmVRQ01yOUkyQk51eGJyaUttcTZVNTE4WGtxOFlZV3o5VEFJR3EwNXlmRVdWVVpzDQo2TG1XWlFYeVpFckwwa3R6UjdCeDRiMzVrWWp1MXJSUThMY24zQzFFKzUyNzhLbUQwYUwxdFhSVWIyZXdNTjB0DQpWdHJyMG5GdVI0amlGbmo1MzQxaUZlTlh1SEFmdSsvNmV4SjA3dTVOV2I5TEVKY2hHcUtoT3pCMHZ6SDVLS0ZxDQppaTZBd0FKYVcwbmwyaDBXOWFvT3Q3S0pqWXJVZndHbGRadlY3MDV6NzhHbHlGMlhLcHpnREw5TlNGRTJHQmY4DQpML1d5amQ5bGtkLzA0SjZMRFVXMm1EcTNPM2tZTVE4ZU9YS3NCcVc3L0t2SWl3SURBUUFCbzRJRG1qQ0NBNVl3DQpId1lEVlIwakJCZ3dGb0FVZElXQXdHYkgzemZlejcwcE42b0RIYjd0elJjd0hRWURWUjBPQkJZRUZEOUpFRmIxDQo1czR2bnh3d2c5TWE3YUVDMlYxdk1Da0dBMVVkRVFRaU1DQ0NEeW91WlhWeWIzQnZjblJ6TG1OdmJZSU5aWFZ5DQpiM0J2Y25SekxtTnZiVEErQmdOVkhTQUVOekExTURNR0JtZUJEQUVDQWpBcE1DY0dDQ3NHQVFVRkJ3SUJGaHRvDQpkSFJ3T2k4dmQzZDNMbVJwWjJsalpYSjBMbU52YlM5RFVGTXdEZ1lEVlIwUEFRSC9CQVFEQWdXZ01CMEdBMVVkDQpKUVFXTUJRR0NDc0dBUVVGQndNQkJnZ3JCZ0VGQlFjREFqQ0Jud1lEVlIwZkJJR1hNSUdVTUVpZ1JxQkVoa0pvDQpkSFJ3T2k4dlkzSnNNeTVrYVdkcFkyVnlkQzVqYjIwdlJHbG5hVU5sY25SSGJHOWlZV3hITWxSTVUxSlRRVk5JDQpRVEkxTmpJd01qQkRRVEV0TVM1amNtd3dTS0JHb0VTR1FtaDBkSEE2THk5amNtdzBMbVJwWjJsalpYSjBMbU52DQpiUzlFYVdkcFEyVnlkRWRzYjJKaGJFY3lWRXhUVWxOQlUwaEJNalUyTWpBeU1FTkJNUzB4TG1OeWJEQ0Jod1lJDQpLd1lCQlFVSEFRRUVlekI1TUNRR0NDc0dBUVVGQnpBQmhoaG9kSFJ3T2k4dmIyTnpjQzVrYVdkcFkyVnlkQzVqDQpiMjB3VVFZSUt3WUJCUVVITUFLR1JXaDBkSEE2THk5allXTmxjblJ6TG1ScFoybGpaWEowTG1OdmJTOUVhV2RwDQpRMlZ5ZEVkc2IySmhiRWN5VkV4VFVsTkJVMGhCTWpVMk1qQXlNRU5CTVMweExtTnlkREFNQmdOVkhSTUJBZjhFDQpBakFBTUlJQmZnWUtLd1lCQkFIV2VRSUVBZ1NDQVc0RWdnRnFBV2dBZFFBUzhVNDB2Vk55VElRR0djT1BQM29UDQorT2UxWW9lSW5HMHdCWVRyNVlZbU9nQUFBWkpTTFRnbkFBQUVBd0JHTUVRQ0lHcUxzWG1jbjFWakVic1l1S2ZaDQphSHV2dDJOUk1qZVFCNXFJdDF2V0I5NjdBaUFLaFhpVXdwVmhYU2dyRHhxaU0zb3FuY1RkS3V4MDB3S0lYRXVhDQpEMjFpeWdCMkFPYlNNV05BZDR6QkVFRUcxM0c1enNIU1FQYVdoSWI3dW9jeUhmMGVONDVRQUFBQmtsSXRPSElBDQpBQVFEQUVjd1JRSWhBS1BveFRvVlNEQy94Z0hyR2RUYTVLWVNtblBNTUcweUg4VlNtODdxSXQ1MUFpQmFBbzFHDQoxNkFuUTJSTE5veGl5OTRRRDFHTmtmRG5XZ1ExYWVkSmNsRWxIQUIzQU16N0QycUZjUWxsL3BXYlU4N3BzbndpDQo2WVZjRFplTnRxbCtWTUQrVEEyd0FBQUJrbEl0T0dNQUFBUURBRWd3UmdJaEFPMFJScUc3YTVQalEwVDBOQ3FpDQpabG1HREx6M0xudFhKODJyWHd3QTVmRmdBaUVBbEdhbzVaeHQyNWcrMUxhc3RlQ01PL3JaY1VFTzVCTzNYT3ZFDQozQzIrOVZJd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFMYjFkeEphK0VQK29SZHdqUElHL3FjUy9aZWFua0ZpDQpINGZ1YVU2ZDNiVkVGUHUvb3FkdGJPcXBZTTF2ZEZZWmdOWVgxeGJweFMwL3g5WjdESUR4dFJBcmE5UzRrbXJVDQpnZmpWSE1MajhzaTlsbm1wRXVDNTZDZ0xVMWdSOGJGNTZsVDVNV0lpejRnSjBjM2pMaXd6bE1nTlVYSE5YOXZTDQovZXZYT1l1OU1VaWtNWFI4UTN4T0d2ZHFiL2xjeExJekpUQ3ZRRlZlTTRaWlJ3TTZvdUxySHlYM3lVQXZMcmxKDQo2ZHBBZDZISElKWFdkYUFQMUNMMFpjcWNOOGdYbnZVelRQaEtCUUZwVkJOd2VQTWx3S2tjcFZiaW1DeG0xZDh2DQp3Rlg3OXp0SVMrZUdNL2Z1U1pnZHZBdHl5U0lkbHhOOXVsTFBvTWpxVGtDOFJTVHRnMFFGUFVBPQ0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ0K'
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_ep_agw_eterminal_api_prd_01_externalid
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'eTerminalapi'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/backendAddressPools/eTerminalapi'
        properties: {
          backendAddresses: [
            {
              fqdn: 'ec524-api.euroports.com'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'StandardHttps'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/backendHttpSettingsCollection/StandardHttps'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          authenticationCertificates: [
            {
              id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/authenticationCertificates/EuroportsWildcard2024-2025'
            }
          ]
        }
      }
    ]
    httpListeners: [
      {
        name: 'Public-Listener'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/httpListeners/Public-Listener'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/sslCertificates/certwildcard'
          }
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
    ]
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'Public-Listener'
        id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/requestRoutingRules/Public-Listener'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/httpListeners/Public-Listener'
          }
          backendAddressPool: {
            id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/backendAddressPools/eTerminalapi'
          }
          backendHttpSettings: {
            id: '${applicationGateways_agw_step_eterminal_api_prd_westeu_01_name_resource.id}/backendHttpSettingsCollection/StandardHttps'
          }
        }
      }
    ]
    probes: []
    rewriteRuleSets: []
    redirectConfigurations: []
    sslPolicy: {
      policyType: 'Custom'
      minProtocolVersion: 'TLSv1_2'
      cipherSuites: [
        'TLS_RSA_WITH_AES_256_CBC_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256'
        'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'
        'TLS_RSA_WITH_AES_128_GCM_SHA256'
        'TLS_RSA_WITH_AES_128_CBC_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA'
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA'
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA'
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA'
        'TLS_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_RSA_WITH_AES_256_CBC_SHA'
        'TLS_RSA_WITH_AES_128_CBC_SHA'
      ]
    }
    enableHttp2: false
  }
}
