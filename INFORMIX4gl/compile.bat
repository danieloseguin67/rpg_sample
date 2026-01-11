@echo off
REM Windows compilation batch file for Informix 4GL Music Organizer

echo Compiling Informix 4GL Music Organizer...
echo =========================================

REM Set environment if needed (adjust paths as necessary)
REM set INFORMIXDIR=C:\Informix
REM set PATH=%INFORMIXDIR%\bin;%PATH%

REM Compile form files
echo Compiling forms...
form4gl musiclist.per
if errorlevel 1 (
    echo Error compiling musiclist form
    exit /b 1
)

form4gl songdetail.per
if errorlevel 1 (
    echo Error compiling songdetail form
    exit /b 1
)

REM Compile 4GL program
echo Compiling 4GL program...
c4gl -o musicorg.exe musicorg.4gl
if errorlevel 0 (
    echo Compilation successful!
    echo Run with: musicorg.exe
    echo.
    echo Make sure the 'organiste' database exists and contains the music table.
    echo See README.md for database setup instructions.
) else (
    echo Error compiling 4GL program
    exit /b 1
)