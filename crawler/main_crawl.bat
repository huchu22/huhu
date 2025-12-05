@echo off
call C:\huhu\crawler\.venv\Scripts\activate.bat
cd /d C:\huhu\crawler
python main_crawl.py
deactivate
pause