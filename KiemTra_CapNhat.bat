@echo off
setlocal
chcp 65001 >nul
title FEΔR Team - Grounded 2 Auto Updater
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0KiemTra_CapNhat.ps1"
