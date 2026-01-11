@echo off
REM Transfer Music Organizer files to IBM i system
REM Modify the variables below for your environment

SET IBM_SYSTEM=your_ibmi_system_name
SET USER_ID=your_userid
SET LIBRARY=MUSICLIB

echo ====================================================
echo Music Organizer - File Transfer to IBM i
echo ====================================================
echo.
echo System: %IBM_SYSTEM%
echo Library: %LIBRARY%
echo User: %USER_ID%
echo.

REM Check if FTP is available
ftp -? >nul 2>&1
if errorlevel 1 (
    echo ERROR: FTP command not found. Please install FTP client.
    pause
    exit /b 1
)

echo Creating FTP script...

REM Create temporary FTP script
echo user %USER_ID% > ftp_script.tmp
echo ascii >> ftp_script.tmp
echo quote site namefmt 1 >> ftp_script.tmp
echo quote rcmd crtlib lib(%LIBRARY%) text('Music Organizer Library') >> ftp_script.tmp
echo quote rcmd crtsrcpf file(%LIBRARY%/qddssrc) rcdlen(112) >> ftp_script.tmp
echo quote rcmd crtsrcpf file(%LIBRARY%/qrpglesrc) rcdlen(112) >> ftp_script.tmp
echo put MUSICDSPF.DSPF %LIBRARY%/qddssrc.musicdspf >> ftp_script.tmp
echo put MUSICPGM.SQLRPGLE %LIBRARY%/qrpglesrc.musicpgm >> ftp_script.tmp
echo quit >> ftp_script.tmp

echo Connecting to %IBM_SYSTEM%...
echo You will be prompted for your password.
echo.

ftp -n -i -s:ftp_script.tmp %IBM_SYSTEM%

REM Clean up
del ftp_script.tmp

echo.
echo ====================================================
echo File transfer completed.
echo.
echo Next steps:
echo 1. Sign on to %IBM_SYSTEM%
echo 2. Run: ADDLIBLE %LIBRARY%
echo 3. Compile display file: 
echo    CRTDSPF FILE(%LIBRARY%/MUSICDSPF) SRCFILE(%LIBRARY%/QDDSSRC) SRCMBR(MUSICDSPF)
echo 4. Compile program:
echo    CRTSQLRPGI OBJ(%LIBRARY%/MUSICPGM) SRCFILE(%LIBRARY%/QRPGLESRC) SRCMBR(MUSICPGM)
echo 5. Run program:
echo    CALL %LIBRARY%/MUSICPGM
echo ====================================================
echo.
pause