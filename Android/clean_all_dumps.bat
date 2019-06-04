SET ROOT_DIRECTORY=%cd%
SET PROJ_DIRECTORY=%cd%/_projects
cd "%PROJ_DIRECTORY%"
for /f %%f in ('dir /b /AD') do (
	echo ::::::: making project[ %%f ]:::::::::
	rmdir /s /q "%cd%/%%f/dump"
)
cd %ROOT_DIRECTORY%
SET PROJ_DIRECTORY=%cd%/_setup
cd "%PROJ_DIRECTORY%"
gradlew.bat clean
cd %ROOT_DIRECTORY%