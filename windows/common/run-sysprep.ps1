Write-Host "Start Sysprep script"

$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

<#
@('c:\unattend.xml', 'c:\windows\panther\unattend\unattend.xml', 'c:\windows\panther\unattend.xml', 'c:\windows\system32\sysprep\unattend.xml') | %{
	if (test-path $_){
		write-host "Removing $($_)"
		remove-item $_ > $null
	}	
}
#>

#Fix the registry to make sysprep actually work
Set-ItemProperty -Path 'HKLM:\SYSTEM\Setup\Status\SysprepStatus' -Name GeneralizationState -Type DWord -Force -Value 7


Write-Host Starting Sysprep Command at (Get-Date).DateTime
if (Test-Path 'a:\sysprep-unattend.xml'){
	& c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /mode:vm /quit /unattend:a:\sysprep-unattend.xml
} elseif (Test-Path 'e:\sysprep-unattend.xml'){
	& c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /mode:vm /quit /unattend:e:\sysprep-unattend.xml
} else {
	& c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /mode:vm /quit /unattend:f:\sysprep-unattend.xml
}
Write-Host Sysprep finish at (Get-Date).DateTime

write-host "Running shutdown"
Stop-Computer -Force

write-host "Return exit 0"
exit 0 