@echo off
set CURRENT_FOLDER=%~dp0
set ARGS="%CURRENT_FOLDER%\..\ecs.csc"
:LOOP
    set index=%1
    if %index%! == ! goto END
    set ARGS=%ARGS% %index%
    shift
    goto LOOP
:END
cs -i "%CURRENT_FOLDER%\..\imports" %ARGS%