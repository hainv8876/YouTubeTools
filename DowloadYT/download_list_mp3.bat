@echo off
setlocal enabledelayedexpansion
if not exist "Music" mkdir "Music"
set /p url=Nhap link playlist YouTube: 
yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --ffmpeg-location "%~dp0." -o "Music/%(title)s.%(ext)s" "%url%"
echo.
echo Hoan tat! File MP3 da luu trong thu muc Music.
pause
