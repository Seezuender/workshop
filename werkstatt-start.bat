@echo off
setlocal
REM Startet die Werkstatt-Auftragsverwaltung in Google Chrome ueber einen lokalen Server,
REM der das Zwischenspeichern unterbindet. Diese drei Dateien gehoeren in denselben Ordner:
REM   werkstatt-start.bat, werkstatt-server.py, werkstattauftraege.html

cd /d "%~dp0"

if not exist "werkstattauftraege.html" (
  echo werkstattauftraege.html wurde in diesem Ordner nicht gefunden.
  pause
  exit /b 1
)
if not exist "werkstatt-server.py" (
  echo werkstatt-server.py fehlt - bitte mit in diesen Ordner legen.
  pause
  exit /b 1
)

set PORT=8765
set URL=http://localhost:%PORT%/werkstattauftraege.html

set "CHROME="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined CHROME if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined CHROME if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" set "CHROME=%LocalAppData%\Google\Chrome\Application\chrome.exe"
if not defined CHROME (
  for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe" /ve 2^>nul') do set "CHROME=%%B"
)
if not defined CHROME (
  for /f "skip=2 tokens=2,*" %%A in ('reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe" /ve 2^>nul') do set "CHROME=%%B"
)
if not defined CHROME (
  echo Google Chrome wurde nicht gefunden. Pfad oben bei CHROME= eintragen.
  pause
  exit /b 1
)

echo.
echo   Werkstattauftraege   [Starter 2026-08-09 / 2 - normales Fenster]
echo   Ordner : %CD%
echo   Adresse: %URL%
echo.
echo   Der Server liefert ohne Zwischenspeicher aus - nach dem Austausch
echo   einer Datei genuegt ein normales Neuladen (F5).
echo.

REM Bewusst OHNE --app, damit Adressleiste, Lesezeichen und Menue sichtbar bleiben.
start "" "%CHROME%" --new-window "%URL%"

python werkstatt-server.py %PORT%
if errorlevel 1 py werkstatt-server.py %PORT%
