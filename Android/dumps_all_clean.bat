REM cd _setup
REM gradlew clean
REM cd ..
SET ROOT_DIRECTORY=%cd%
SET PROJS_DIRECTORY=%cd%/_completed
cd "%PROJS_DIRECTORY%"
for /f %%f in ('dir /b /AD') do (
	echo ::::::: making project[ %%f ]:::::::::
	rmdir /s /q "%cd%/%%f/dump"
)
cd %ROOT_DIRECTORY%