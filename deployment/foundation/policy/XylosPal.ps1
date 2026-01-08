Install-Module -Name Az.ManagementPartner -Scope CurrentUser -Force

$Pal = Get-AzManagementPartner -ErrorAction SilentlyContinue
If(!($Pal))
{
    New-AzManagementPartner -PartnerId 503476
}