@echo off
rd /S /Q build
mkdir build\bin
xcopy /Y ecs build\bin\
xcopy /Y ecs.bat build\bin\