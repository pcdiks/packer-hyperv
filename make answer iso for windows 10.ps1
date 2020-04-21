$osFolder = 'windows-10-amd64'
$isoFolder = 'answer-iso'
if (test-path $isoFolder){
	remove-item $isoFolder -Force -Recurse
}

if (test-path windows\$osFolder\answer.iso){
	remove-item windows\$osFolder\answer.iso -Force
}

$ENV:UnAttendUseUefi = $false
$ENV:UnAttendUseCdrom = $true

& .\windows\update-variables.ps1

mkdir $isoFolder

Copy-Item windows\$osFolder\Autounattend.xml $isoFolder\
Copy-Item windows\$osFolder\sysprep-unattend.xml $isoFolder\
if (Test-Path windows\$osFolder\Software.zip) {Copy-Item windows\$osFolder\Software.zip $isoFolder\}
if (Test-Path windows\$osFolder\Customize-System.ps1) {Copy-Item windows\$osFolder\Customize-System.ps1 $isoFolder\}
Copy-Item windows\common\variables.ps1 $isoFolder\

Copy-Item windows\common\set-power-config.ps1 $isoFolder\
Copy-Item windows\common\microsoft-updates.ps1 $isoFolder\
Copy-Item windows\common\win-updates.ps1 $isoFolder\
Copy-Item windows\common\run-sysprep.ps1 $isoFolder\
Copy-Item windows\common\run-sysprep.cmd $isoFolder\
Copy-Item windows\common\oracle-cert.cer $isoFolder\
Copy-Item windows\common\enable-winrm.ps1 $isoFolder\
Copy-Item windows\common\enable-winrm.task.ps1 $isoFolder\
Copy-Item windows\common\fixnetwork.ps1 $isoFolder\
Copy-Item windows\common\sdelete.exe $isoFolder\
Copy-Item windows\common\sdelete.ps1 $isoFolder\
Copy-Item windows\common\elevate.exe $isoFolder\
Copy-Item windows\common\Set-ClientWSUSSetting.ps1 $isoFolder\
Copy-Item windows\common\Set-ClientWSUSSetting.task.ps1 $isoFolder\
Copy-Item windows\common\Reset-ClientWSUSSetting.ps1 $isoFolder\


& .\mkisofs.exe -r -iso-level 4 -UDF -o windows\$osFolder\answer.iso $isoFolder

if (test-path $isoFolder){
	remove-item $isoFolder -Force -Recurse
}