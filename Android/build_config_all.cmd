@echo off
cls
echo ::::::: Setting initial Path [BEGINE] :::::::::
chcp 65001
SET ROOT_DIRECTORY=%cd%
SET PROJS_DIRECTORY=%cd%/_projects
SET TOOLS_DIRECTORY=%cd%/_tools
SET SETUP_DIRECTORY=%cd%/_setup
SET PATH_BACKUP=%path%
SET path=%PATH_BACKUP%;%TOOLS_DIRECTORY%/notifu-1.6
echo ::::::: Setting initial Path [DONE] :::::::::
echo ::::::: Checking System Requirements [BEGINE] :::::::::
if "%ANDROID_SDK_PATH%"=="" (
	echo ::::::: ERROR:: 'ANDROID_SDK_PATH' is not defined in your environment variables. :::::::
	goto Error
) 
echo ::::::: Checking System Requirements [DONE] :::::::::
echo ::::::: Building Projects [BEGINE] :::::::::
cd "%PROJS_DIRECTORY%"
echo ################# before loop... ########################
for /f %%f in ('dir /b /AD') do (
	echo ################# inside loop... ########################
	echo ::::::: making project[ %cd%/%%f ]:::::::::
	java -jar -Dfile.encoding=UTF-8 "%TOOLS_DIRECTORY%\APKBiilder3.jar" "%SETUP_DIRECTORY%" "%cd%/%%f" "config"
	cd..
	cd..
)
goto end

@echo on
:Error
	echo build process stopped, an error occured
	@notifu /p "Setup Failed" /m "Please check the Command Window for Build Status and Errors/Warning" /t error /d 15 /i notifu.exe
	
	cd %ROOT_DIRECTORY%

	SET ROOT_DIRECTORY=
	SET PROJS_DIRECTORY=
	SET TOOLS_DIRECTORY=
	SET SETUP_DIRECTORY=
	SET path=%PATH_BACKUP%
	endlocal

:end
	echo ::::::: Building Projects [DONE] :::::::::
	@notifu /p "Setup Completed" /m "Please check the Command Window for Build Status and Errors/Warning" /d 15 /i notifu.exe

	cd %ROOT_DIRECTORY%
	
	::explorer "%PROJS_DIRECTORY%"

	SET ROOT_DIRECTORY=
	SET PROJS_DIRECTORY=
	SET TOOLS_DIRECTORY=
	SET SETUP_DIRECTORY=
	SET path=%PATH_BACKUP%