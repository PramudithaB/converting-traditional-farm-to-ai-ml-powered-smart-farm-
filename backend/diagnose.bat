@echo off
REM Smart Farm Backend - Troubleshooting Script (Windows)
REM Run this to diagnose why models aren't loading

echo ================================================
echo Smart Farm Backend - Model Loading Diagnostics
echo ================================================
echo.

echo 1. Current Directory:
cd
echo.

echo 2. Expected Directory:
echo    Should end with: \backend
echo.

echo 3. Checking Model Files:
echo.

if exist "animal_birth\clf.pkl" (
    echo    [OK] Found: animal_birth\clf.pkl
) else (
    echo    [X] Missing: animal_birth\clf.pkl
)

if exist "cow_identify\best.pt" (
    echo    [OK] Found: cow_identify\best.pt
) else (
    echo    [X] Missing: cow_identify\best.pt
)

if exist "egg_hatch\egg_hatch_nn.h5" (
    echo    [OK] Found: egg_hatch\egg_hatch_nn.h5
) else (
    echo    [X] Missing: egg_hatch\egg_hatch_nn.h5
)

if exist "milk_market_prediction\rf_milk_price_model.pkl" (
    echo    [OK] Found: milk_market_prediction\rf_milk_price_model.pkl
) else (
    echo    [X] Missing: milk_market_prediction\rf_milk_price_model.pkl
)

if exist "nutrition_recommended\multi_output_nutrition_model.pkl" (
    echo    [OK] Found: nutrition_recommended\multi_output_nutrition_model.pkl
) else (
    echo    [X] Missing: nutrition_recommended\multi_output_nutrition_model.pkl
)

if exist "cow_daily_feed\models\best_seg_model.h5" (
    echo    [OK] Found: cow_daily_feed\models\best_seg_model.h5
) else (
    echo    [X] Missing: cow_daily_feed\models\best_seg_model.h5
)

if exist "cattle_disease_detection\models\DenseNet121_Disease\best_model.h5" (
    echo    [OK] Found: cattle_disease_detection\models\DenseNet121_Disease\best_model.h5
) else (
    echo    [X] Missing: cattle_disease_detection\models\DenseNet121_Disease\best_model.h5
)

echo.
echo 4. Diagnosis:
echo.

if not exist "animal_birth\clf.pkl" (
    echo    [X] PROBLEM: Models not found!
    echo.
    echo    SOLUTION: You are NOT in the backend directory.
    echo.
    echo    Run these commands:
    echo    cd backend
    echo    python app.py
    echo.
) else (
    echo    [OK] Models found! Directory is correct.
    echo.
    echo    If models still fail, check Python dependencies:
    echo    pip install -r requirements.txt
    echo.
)

echo ================================================
pause
