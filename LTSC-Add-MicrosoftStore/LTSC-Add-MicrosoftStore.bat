@echo off
:: 以 Bypass 策略调用 PowerShell 脚本，并要求管理员权限
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy Bypass','-File','\"%~dp0LTSC-Add-MicrosoftStore.ps1\"'"