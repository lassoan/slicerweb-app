@echo off
rem Publish what build.bat built last, to a channel: latest (default), stable, a version (1.0.0), ...
rem It goes to the release runtime-<channel> of this repository and from there to branch
rem deploy/<channel>, with the web application of the SlicerWeb commit the build was made from.
rem Nothing is built here: what is published is what was built (and what serve-local.bat shows).
rem
rem     deploy.bat              channel latest
rem     deploy.bat stable       channel stable
rem
rem Runs in the SlicerWeb checkout next to this folder (or the one SLICERWEB names), whose commit
rem the build was made from has to be pushed. Needs Python and the GitHub CLI (gh auth login).
setlocal
set "CHANNEL=%~1"
if "%CHANNEL%"=="" set "CHANNEL=latest"
set "DEPLOY=%~dp0"
set "DEPLOY=%DEPLOY:~0,-1%"
if not defined SLICERWEB set "SLICERWEB=%DEPLOY%\..\SlicerWeb"
if not exist "%SLICERWEB%\build.py" (
  echo SlicerWeb checkout not found: %SLICERWEB% ^(set SLICERWEB to its folder^)
  exit /b 1
)

pushd "%SLICERWEB%"
python scripts\publish_runtime.py --deployment "%DEPLOY%" --channel "%CHANNEL%" --publish
if errorlevel 1 goto failed
popd
echo Published channel %CHANNEL%: branch deploy/%CHANNEL%
exit /b 0

:failed
popd
echo Deployment of channel %CHANNEL% failed
exit /b 1
