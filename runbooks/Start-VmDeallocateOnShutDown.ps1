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
        $virtualMachine = Get-AzVM -VMName $vm -Status
        Write-Output $alert
        if($virtualMachine.PowerState -ne "Starting" -or $virtualMachine.PowerState -ne "VM deallocated")
        {
            Write-Output "Deallocating VM:$($VMNames)"
            $stopVm = Stop-AzVm -Name $virtualMachine.name -ResourceGroupname $virtualMachine.resourceGroupname -Force
            if($stopVM)
            {
                Write-Output "Deallocated VM:$($VMNames)"
                Update-AzAlertState -AlertId $alert -State Closed
            }
        }
        else
        {
            Update-AzAlertState -AlertId $alert -State Closed
            Write-Host "VM will not be deallocated"
        }
}
Update-AzAlertState