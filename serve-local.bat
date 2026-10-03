@echo off
rem Try the local build of this deployment in the browser, before publishing it: builds the web
rem application of the SlicerWeb checkout next to this folder (or the one SLICERWEB names) around
rem the wheels and extensions of the last build (build.bat), serves it at http://localhost:4176/ and
rem opens it: what deploy.bat would publish. To stop it: Ctrl+C in its window, then Y (or close
rem the window), or stop-local.bat for one without a window. The version of the build is at the
rem end of the menu of the application.
rem
rem     serve-local.bat [port]
rem
rem Needs Node.js. The sample data sets are downloaded once, into the dist folder of the deployment.
setlocal
set "PORT=%~1"
if "%PORT%"=="" set "PORT=4176"
set "DEPLOY=%~dp0"
set "DEPLOY=%DEPLOY:~0,-1%"
if not defined SLICERWEB set "SLICERWEB=%DEPLOY%\..\SlicerWeb"
if not exist "%SLICERWEB%\web\package.json" (
  echo SlicerWeb checkout not found: %SLICERWEB% ^(set SLICERWEB to its folder^)
  exit /b 1
)

rem The dist folder of the deployment, as build.py finds it: SW_DIST, else local.env, else the default
set "DIST=%SW_DIST%"
if not defined DIST if exist "%DEPLOY%\local.env" (
  for /f "usebackq tokens=1,* delims==" %%a in ("%DEPLOY%\local.env") do if "%%a"=="SW_DIST" set "DIST=%%b"
)
if not defined DIST (
  for %%f in ("%DEPLOY%") do set "DIST=%USERPROFILE%\SlicerWeb-build\dist-%%~nxf"
)
if not exist "%DIST%\wheels" (
  echo No build in %DIST%: run build.bat
  exit /b 1
)
echo Runtime: %DIST%

rem A server already on the port (another serve-local.bat, maybe one without a window) would only
rem be found once the web application is built
powershell -NoProfile -Command "if (Get-NetTCPConnection -LocalPort %PORT% -State Listen -ErrorAction SilentlyContinue) { exit 1 }"
if errorlevel 1 (
  echo Port %PORT% is already in use: a server is running there. Stop it with stop-local.bat %PORT%,
  echo or open http://localhost:%PORT%/ if it is the one you want.
  exit /b 1
)

set "SLICERWEB_WHEELS=%DIST%\wheels"
set "SLICERWEB_EXTENSIONS=%DIST%\extensions"
set "SLICERWEB_SAMPLE_DATA=%DIST%\sample-data"
set "VITE_CONFIG_NATIVE_IGNORE_WARNING=true"

pushd "%SLICERWEB%\web"
if not exist node_modules (
  call npm install
  if errorlevel 1 goto failed
)
call node scripts\fetch-sample-data.mjs
if errorlevel 1 goto failed
call npx vite build --outDir "%DIST%\web" --emptyOutDir
if errorlevel 1 goto failed
call npx vite preview --outDir "%DIST%\web" --port %PORT% --strictPort --open
popd
exit /b 0

:failed
popd
echo The local server could not be started
exit /b 1
