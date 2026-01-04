#!/bin/bash

echo "===================================="
echo "Smart Farm AI Backend - Quick Start"
echo "===================================="
echo ""

cd "$(dirname "$0")"

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo ""
fi

echo "Activating virtual environment..."
source venv/bin/activate
echo ""

echo "Installing/Updating dependencies..."
pip install -r requirements.txt
echo ""

echo "===================================="
echo "Starting Smart Farm AI Backend..."
echo "===================================="
echo "Server will run on http://localhost:5000"
echo "Press Ctrl+C to stop the server"
echo ""

python app.py
