@echo off
cd %~dp0
candle .\ecs_wix.wxs -nologo
light -ext WixUIExtension -b . -cultures:en-us .\ecs_wix.wixobj -out extended-covscript-x64.msi -nologo
del /Q ecs_wix.wixobj
del /Q extended-covscript-x64.wixpdb