
[CmdletBinding()]
param (
	[parameter(mandatory = $true)]$VMNames,
    [parameter(mandatory = $true)]$Environment
)

# Connect using a Managed Service Identity
try
{
    $AzureContext = (Connect-AzAccount -Identity -Environment $Environment).context
}
catch
{
    Write-Output "There is no system-assigned user identity. Aborting.";
    exit
}

$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

Foreach ($vm in $VMNames)
{
        Write-Output "Deallocated VM:$($VMNames)"
        $virtualMachine = Get-AzVM -VMName $vm
        Stop-AzVm -Name $virtualMachine.name -ResourceGroupname $virtualMachine.resourceGroupname -Force
}