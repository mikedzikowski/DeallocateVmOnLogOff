[CmdletBinding()]
param (
	[parameter(mandatory = $true)]$VMNames,
    [parameter(mandatory = $true)]$Environment,
    [parameter(mandatory = $true)]$AlertId
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

$VMNames = $VMNames.split('/')[8]
$alert = $AlertId.split('/')[6]

Foreach ($vm in $VMNames)
{
        Write-Output "Deallocated VM:$($VMNames)"
        $virtualMachine = Get-AzVM -VMName $vm -Status 
        if($virtualMachine.Statuses -eq "stopped")
        {
            $stopVm = Stop-AzVm -Name $virtualMachine.name -ResourceGroupname $virtualMachine.resourceGroupname -Force
            if($stopVM)
            {
                Update-AzAlertState -Alert $alert -State Closed
            }
        }
        else
        {
            Write-Host "VM is not stopped and will not be deallocated"
        }
}
