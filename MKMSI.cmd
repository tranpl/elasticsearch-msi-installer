@echo off
rem #### #### DO NOT EDIT THIS FILE ##### ####
rem Copyright 2014-2015 Hendrik Saly
rem Licensed under the Apache License, Version 2.0

call "%~dp0config.cmd"

IF NOT DEFINED GENERATED_TOP_FOLDER (goto badenv)

IF EXIST "%~dp0%PACKAGE_FOLDER%" (goto exists) else goto notexists

:notexists
echo.
echo --------------------------------------
echo ### ERROR #### Execute DUPC.cmd first!
echo --------------------------------------
echo.
rem pause
goto eof

:exists
set WIX_HOME="%~dp0%WIX_FOLDER%"
set ROOT="%~dp0%PACKAGE_FOLDER%"
set TEMP="%~dp0%WIX_FOLDER%"
set MSI_FOLDER="%~dp0%GENERATED_TOP_FOLDER%\msi"

del /f /q %TEMP%\*.wixobj >NUL 2>&1
del /f /q %TEMP%\*.wxs >NUL 2>&1

rmdir /s /q %MSI_FOLDER%  >NUL 2>&1
echo.
echo *** Starting phase "MKMSI" (Make MSI) ***
echo.
%WIX_HOME%\heat.exe dir %ROOT% -cg MyFiles -gg -scom -sreg -sfrag -dr INSTALLDIR -out %TEMP%\FileFragment.wxs -var var.InstallerPath
	
%WIX_HOME%\candle.exe -dInstallerPath=%ROOT% -dEsiVersion=%ES_DIST_VERSION%.%ESI_VERSION% -dEsFolder=%PACKAGE_FOLDER_NAME%\%ES_DIST_NAME%  -dPlatform=x86 -arch x86  -out %TEMP%\ %TEMP%\FileFragment.wxs  "%~dp0%Product.wxs" 
  
%WIX_HOME%\light.exe -out %MSI_FOLDER%\ESI-%ES_DIST_VERSION%.%ESI_VERSION%-j%JAVA_DIST_VERSION%.msi -cultures:null -spdb -sval  %TEMP%\FileFragment.wixobj %TEMP%\Product.wixobj
echo.
echo Finished with phase "MKMSI" (Make MSI)
echo You should now find your final .msi file here: %MSI_FOLDER%
echo.
rem pause
goto :eof

:badenv
echo Bad environment, check config.cmd
rem pause