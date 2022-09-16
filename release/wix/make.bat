candle .\ecs_wix.wxs -nologo
light -ext WixUIExtension -b . -cultures:en-us .\ecs_wix.wixobj -out extended_covscript_x86.msi -nologo
del /Q ecs_wix.wixobj
del /Q extended_covscript_x86.wixpdb