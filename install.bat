@echo off
echo installing asset downloader...
cd rbx-plugin
move AssetDownloader.lua %localappdata%\Roblox\Plugins
cd %~dp0
rmdir rbx-plugin
echo COPY/PASTE URLS HERE, AND DELETE THIS TEXT! > astUrls.txt
echo Enter API key here (DELETE THIS TEXT) > key.txt
echo installed successfully!