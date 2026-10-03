@echo off
rem Build this deployment: SlicerWeb (the checkout next to this folder, or the one SLICERWEB names)
rem with the extensions of SlicerWeb that extensions.json names and those of extensions\. Try the build
rem with serve-local.bat, publish it with deploy.bat.
rem
rem     build.bat                                  everything (default)
rem     build.bat extensions                       all extensions
rem     build.bat SlicerIGT                        these extensions (names in extensions.json or of extensions\*.json)
rem     build.bat 60-wheels                        these stages of the SlicerWeb build (scripts\stages)
rem
rem Everything means every stage, each redoing only what changed since the last build: a few minutes
rem when nothing did, hours when VTK, ITK or Slicer moved. An extension is built at the revision of
rem its description file.
rem
rem SlicerWeb is built as its checkout is: update it first (git pull there). The build writes the
rem date and the commits of SlicerWeb and of this repository into the build, and the application
rem shows them at the end of its menu. Needs Docker, Python and .secrets\github-token (README.md).
setlocal
set "DEPLOY=%~dp0"
set "DEPLOY=%DEPLOY:~0,-1%"
if not defined SLICERWEB set "SLICERWEB=%DEPLOY%\..\SlicerWeb"
if not exist "%SLICERWEB%\build.py" (
  echo SlicerWeb checkout not found: %SLICERWEB% ^(set SLICERWEB to its folder^)
  exit /b 1
)

set "STAGES="
set "EXTENSIONS="
:arguments
if "%~1"=="" goto arguments_done
set "ARG=%~1"
if /i "%ARG%"=="all" (
  set "STAGES=%STAGES% all"
) else if /i "%ARG%"=="extensions" (
  set "STAGES=%STAGES% 80-extensions"
) else if exist "%SLICERWEB%\scripts\stages\%ARG%.sh" (
  set "STAGES=%STAGES% %ARG%"
) else if exist "%DEPLOY%\extensions\%ARG%.json" (
  set "EXTENSIONS=%EXTENSIONS% %ARG%"
) else (
  rem an extension of SlicerWeb that extensions.json names
  findstr /c:"\"%ARG%\"" "%DEPLOY%\extensions.json" >nul 2>nul && (
    set "EXTENSIONS=%EXTENSIONS% %ARG%"
  ) || (
    echo Not an extension of extensions.json or extensions\, nor a stage of the build: %ARG%
    exit /b 1
  )
)
shift
goto arguments
:arguments_done

set "OPTIONS="
if defined EXTENSIONS (
  set "OPTIONS=--extensions "%EXTENSIONS:~1%""
  echo %STAGES% | findstr /i /c:"80-extensions" /c:" all" >nul || set "STAGES=%STAGES% 80-extensions"
)
if not defined STAGES set "STAGES= all"

for /f "delims=" %%c in ('git -C "%SLICERWEB%" log -1 "--format=%%h %%s"') do echo SlicerWeb: %%c
echo Building:%STAGES% %OPTIONS%
pushd "%SLICERWEB%"
python build.py --deployment "%DEPLOY%" %OPTIONS% %STAGES:~1%
if errorlevel 1 goto failed
popd
echo Built. Try it: serve-local.bat   Publish it: deploy.bat [channel]
exit /b 0

:failed
popd
echo The build failed
exit /b 1
