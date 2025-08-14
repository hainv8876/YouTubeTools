@echo off
setlocal enabledelayedexpansion

REM Đặt thư mục lưu tool
set "WORKDIR=%~dp0Tools"
if not exist "%WORKDIR%" mkdir "%WORKDIR%"

REM ===============================
REM 1. Tải yt-dlp.exe nếu chưa có
REM ===============================
if exist "%WORKDIR%\yt-dlp.exe" (
    echo Da co yt-dlp.exe, bo qua tai...
) else (
    echo Dang tai yt-dlp.exe...
    powershell -Command "Invoke-WebRequest https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -OutFile '%WORKDIR%\yt-dlp.exe'"
)

REM ===============================
REM 2. Kiểm tra ffmpeg
REM ===============================
if exist "%WORKDIR%\ffmpeg.exe" (
    if exist "%WORKDIR%\ffprobe.exe" (
        echo Da co ffmpeg, bo qua tai...
        goto SkipFfmpeg
    )
)

REM Chưa có ffmpeg → tải 7-Zip nếu chưa có
if exist "%WORKDIR%\7z.exe" (
    echo Da co 7z.exe, bo qua tai...
) else (
    echo Dang tai 7-Zip portable...
    powershell -Command "Invoke-WebRequest https://www.7-zip.org/a/7zr.exe -OutFile '%WORKDIR%\7z.exe'"
)

REM Tải ffmpeg
echo Dang tai ffmpeg (64-bit)...
powershell -Command "Invoke-WebRequest https://www.gyan.dev/ffmpeg/builds/packages/ffmpeg-2025-08-11-git-3542260376-full_build.7z -OutFile '%WORKDIR%\ffmpeg.7z'"

REM Giải nén ffmpeg
echo Giai nen ffmpeg...
cd /d "%WORKDIR%"
7z x ffmpeg.7z -y >nul

REM Copy ffmpeg.exe và ffprobe.exe vào thư mục Tools
for /r "%WORKDIR%" %%F in (ffmpeg.exe ffprobe.exe) do (
    copy "%%F" "%WORKDIR%" >nul
)

REM Xóa file nén và thư mục tạm
del "%WORKDIR%\ffmpeg.7z"
for /d %%D in ("%WORKDIR%\ffmpeg*") do rd /s /q "%%D"

:SkipFfmpeg
echo.
echo ===============================
echo Tat ca cong cu da san sang trong thu muc:
echo %WORKDIR%
echo ===============================

@echo off
setlocal enabledelayedexpansion

for /f %%a in ('wmic os get localdatetime ^| find "."') do set ts=%%a
set yyyy=%ts:~0,4%
set mm=%ts:~4,2%
set dd=%ts:~6,2%
set hh=%ts:~8,2%
set nn=%ts:~10,2%
set ss=%ts:~12,2%
set timestamp=%yyyy%%mm%%dd%-%hh%%nn%%ss%


echo ================================
echo Chon che do tai:
echo 1. Tai MP3 cua 1 video
echo 2. Tai MP3 cua playlist
echo 3. Tai MP4 cua 1 video
echo 4. Tai MP4 cua playlist
echo ================================
set /p choice=Nhap so lua chon (1-4): 

REM Tạo thư mục lưu kết quả
set "SAVE_DIR=%choice%_%timestamp%"
mkdir "%~dp0%SAVE_DIR%"
set /p url=Nhap URL: 
REM Hỏi URL

if "%choice%"=="1" (
    "%~dp0Tools\yt-dlp.exe" -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --ffmpeg-location "%WORKDIR%." -o "%~dp0%SAVE_DIR%/%%(title)s.%%(ext)s" "%url%"
) else if "%choice%"=="2" (
    "%~dp0Tools\yt-dlp.exe" --yes-playlist -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --ffmpeg-location "%WORKDIR%." -o "%~dp0%SAVE_DIR%/%%(title)s.%%(ext)s" "%url%"
) else if "%choice%"=="3" (
    "%~dp0Tools\yt-dlp.exe" -f bestvideo+bestaudio --merge-output-format mp4 -o "%~dp0%SAVE_DIR%/%%(title)s.%%(ext)s" "%url%"
) else if "%choice%"=="4" (
    "%~dp0Tools\yt-dlp.exe" -f bestvideo+bestaudio --merge-output-format mp4 -o "%~dp0%SAVE_DIR%/%%(title)s.%%(ext)s" "%url%"
) else (
    echo Lua chon khong hop le.
)

echo.
echo Hoan tat! Ket qua nam trong thu muc "%SAVE_DIR%"
pause
