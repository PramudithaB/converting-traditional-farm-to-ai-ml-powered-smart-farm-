@echo off
echo ====================================
echo Smart Farm AI Backend - Quick Start
echo ====================================
echo.

cd /d "%~dp0"

if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    echo.
)

echo Activating virtual environment...
call venv\Scripts\activate.bat
echo.

echo Installing/Updating dependencies...
pip install -r requirements.txt
echo.

echo ====================================
echo Starting Smart Farm AI Backend...
echo ====================================
echo Server will run on http://localhost:5000
echo Press Ctrl+C to stop the server
echo.

python app.py
