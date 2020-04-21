<#
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1 -Type DWord
enable-psremoting -SkipNetworkProfileCheck -Force
Set-WSManQuickConfig -SkipNetworkProfileCheck -Force
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1 -Type DWord

Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force
Set-Item WSMan:\localhost\Client\AllowUnencrypted -Value $true -Force
Set-Item WSMan:\localhost\Client\Auth\Basic -Value $true -Force

Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true -Force

if ((Get-Item WSMan:\localhost\Service\AllowUnencrypted).Value -ne $true) {
	Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true -Force  #firewall exception will occur if we have any interfaces that are public (fixnetwork.ps1 should make it private)
}

if ((Get-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB).Value -lt 1024) {
	Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB -Value 1024 -Force
}

if ((Get-Item WSMan:\localhost\Shell\MaxShellsPerUser).Value -lt 60) {
  Set-Item WSMan:\localhost\Shell\MaxShellsPerUser -Value 60 -Force
}

if ((Get-Item WSMan:\localhost\Shell\MaxShellRunTime).Value -lt 1800000) {
	Set-Item WSMan:\localhost\Shell\MaxShellRunTime -Value 1800000 -Force #depreceated 
}

Set-Item WSMan:\localhost\Listener\*\Port -Value 5985 -Force
cmd /c sc config winrm start= disabled
#>

# Supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

# Set network to private
$ifaceinfo = Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceIndex $ifaceinfo.InterfaceIndex -NetworkCategory Private 

# Set up WinRM and configure some things
winrm quickconfig -q
winrm s "winrm/config" '@{MaxTimeoutms="1800000"}'
winrm s "winrm/config/winrs" '@{MaxMemoryPerShellMB="2048"}'
winrm s "winrm/config/service" '@{AllowUnencrypted="true"}'
winrm s "winrm/config/service/auth" '@{Basic="true"}'

# Enable the WinRM Firewall rule, which will likely already be enabled due to the 'winrm quickconfig' command above
Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"

#WinRM is enabled when Windows Updates are finished
stop-service winrm
sc config winrm start= disabled


exit 0
