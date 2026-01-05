#!/bin/bash

# Smart Farm Backend - Troubleshooting Script
# Run this to diagnose why models aren't loading

echo "================================================"
echo "Smart Farm Backend - Model Loading Diagnostics"
echo "================================================"
echo ""

echo "1. Current Directory:"
pwd
echo ""

echo "2. Expected Directory:"
echo "   Should end with: /backend"
echo ""

echo "3. Checking Model Files:"
echo ""

check_file() {
    if [ -f "$1" ]; then
        echo "   ✓ Found: $1"
        return 0
    else
        echo "   ✗ Missing: $1"
        return 1
    fi
}

# Check all model files
check_file "animal_birth/clf.pkl"
check_file "cow_identify/best.pt"
check_file "egg_hatch/egg_hatch_nn.h5"
check_file "egg_hatch/egg_hatch_scaler.joblib"
check_file "milk_market_prediction/rf_milk_price_model.pkl"
check_file "nutrition_recommended/multi_output_nutrition_model.pkl"
check_file "cow_daily_feed/models/best_seg_model.h5"
check_file "cow_daily_feed/models/best_reg_model.h5"
check_file "cow_daily_feed/models/cow_feed_predictor.pkl"
check_file "cow_daily_feed/models/breed_encoder.pkl"
check_file "cow_daily_feed/models/activity_encoder.pkl"
check_file "cattle_disease_detection/models/DenseNet121_Disease/best_model.h5"
check_file "cattle_disease_detection/models/All_Cattle_Disease/best.pt"
check_file "cattle_disease_detection/models/All_Behaviore/best.pt"

echo ""
echo "4. Diagnosis:"
echo ""

if [ ! -f "animal_birth/clf.pkl" ]; then
    echo "   ❌ PROBLEM: Models not found!"
    echo ""
    echo "   SOLUTION: You are NOT in the backend directory."
    echo ""
    echo "   Run these commands:"
    echo "   $ cd backend"
    echo "   $ python app.py"
    echo ""
else
    echo "   ✓ Models found! Directory is correct."
    echo ""
    echo "   If models still fail, check Python dependencies:"
    echo "   $ pip install -r requirements.txt"
    echo ""
fi

echo "================================================"
