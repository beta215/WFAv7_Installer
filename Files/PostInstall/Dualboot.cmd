@echo off
setlocal EnableDelayedExpansion

:: Get EFIESP infos

for /f "delims=" %%a in ('fsutil reparsepoint query %SYSTEMDRIVE%\EFIESP') do (
	echo %%a| find "Substitute Name:">nul
	if "!Errorlevel!" EQU "0" (
		for /f "tokens=2 delims=:" %%b in ("%%a") do (
			set "VolumeName=%%b"
			set "Uuid=!VolumeName:*Volume=!"
			set "Uuid=!Uuid:~0,-1!"
			for /f %%p in ('Powershell -C "(Get-Partition | ? { $_.Guid -eq '!Uuid!'}).DiskNumber"') do set "DiskNumber=%%p"
			for /f %%p in ('Powershell -C "(Get-Partition | ? { $_.Guid -eq '!Uuid!'}).PartitionNumber"') do set "PartitionNumber=%%p"
			set "Uuid="
		)
	)
)

:: Dualboot

md Temp\
echo>Temp\diskpart1.txt sel dis !DiskNumber!
echo>>Temp\diskpart1.txt sel par !PartitionNumber!
echo>>Temp\diskpart1.txt set id=ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
diskpart /s Temp\diskpart1.txt
rd /s /q Temp\

bcdedit /store "%SYSTEMDRIVE%\EFIESP\EFI\Microsoft\Boot\BCD" /set "{bootmgr}" "timeout" "5"

echo.
echo Done!
pause
exit /b
