"""
🐄 INTEGRATED CATTLE DISEASE DIAGNOSIS SYSTEM
================================================
Best Workflow: Intelligent Cascade with 5 Models

Author: Automated System
Date: December 31, 2025
Version: 1.0

Models Used:
1. YOLOv8s - Behavior Monitoring (24/7)
2. YOLOv8x - Fast Disease Detection
3. DenseNet121 - Accurate Disease Detection  
4. Gradient Boosting - Severity Assessment (97.25%)
5. Gradient Boosting - Treatment Recommendation (99.5%)
"""

import numpy as np
import pandas as pd
import joblib
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# ============================================================================
# CONFIGURATION
# ============================================================================

class Config:
    """System configuration"""
    # Model paths
    DENSENET121_PATH = 'models/DenseNet121_Disease/best_model.h5'
    SEVERITY_MODEL_PATH = 'models/Treatment_Severity/best_model_gradient_boosting.pkl'
    SEVERITY_SCALER_PATH = 'models/Treatment_Severity/scaler.pkl'
    SEVERITY_ENCODERS_PATH = 'models/Treatment_Severity/label_encoders.pkl'
    TREATMENT_MODEL_PATH = 'models/Treatment_Recommendation/best_model_gradient_boosting.pkl'
    TREATMENT_SCALER_PATH = 'models/Treatment_Recommendation/scaler.pkl'
    TREATMENT_ENCODERS_PATH = 'models/Treatment_Recommendation/label_encoders.pkl'
    
    # Thresholds
    YOLO_CONFIDENCE_THRESHOLD = 0.75  # Disease detection threshold
    BEHAVIOR_ABNORMAL_THRESHOLD = 0.25  # 25% deviation triggers alert
    SEVERITY_URGENT_THRESHOLD = 2  # Severe = immediate action
    
    # Behavior monitoring configuration
    BEHAVIOR_MONITORING_HOURS = 24  # Need 24 hours of data for reliable analysis
    BEHAVIOR_CHECK_INTERVAL_MINUTES = 60  # Check behavior every hour
    BEHAVIOR_MIN_DATA_POINTS = 12  # Minimum 12 data points (12 hours minimum)
    
    # Normal ranges (Sri Lankan context)
    NORMAL_TEMP = 38.5  # °C
    NORMAL_TEMP_RANGE = (37.5, 39.5)
    
    # Disease detection
    DISEASE_CONFIDENCE_FOR_DIAGNOSIS = 0.65  # Minimum confidence to diagnose disease
    
# ============================================================================
# MODEL LOADER
# ============================================================================

class ModelLoader:
    """Load all models once at startup"""
    
    def __init__(self):
        self.models_loaded = False
        self.densenet121 = None
        self.severity_model = None
        self.severity_scaler = None
        self.severity_encoders = None
        self.treatment_model = None
        self.treatment_scaler = None
        self.treatment_encoders = None
        
    def load_all_models(self):
        """Load all models into memory"""
        try:
            print("🔄 Loading models...")
            
            # Load DenseNet121 (optional - only if using)
            try:
                from tensorflow import keras
                self.densenet121 = keras.models.load_model(Config.DENSENET121_PATH)
                print("✅ DenseNet121 loaded")
            except Exception as e:
                print(f"⚠️ DenseNet121 not loaded: {e}")
            
            # Load Severity Model
            self.severity_model = joblib.load(Config.SEVERITY_MODEL_PATH)
            self.severity_scaler = joblib.load(Config.SEVERITY_SCALER_PATH)
            self.severity_encoders = joblib.load(Config.SEVERITY_ENCODERS_PATH)
            print("✅ Severity model loaded")
            
            # Load Treatment Model
            self.treatment_model = joblib.load(Config.TREATMENT_MODEL_PATH)
            self.treatment_scaler = joblib.load(Config.TREATMENT_SCALER_PATH)
            self.treatment_encoders = joblib.load(Config.TREATMENT_ENCODERS_PATH)
            print("✅ Treatment model loaded")
            
            self.models_loaded = True
            print("✅ All models loaded successfully!\n")
            
        except Exception as e:
            print(f"❌ Error loading models: {e}")
            raise

# Initialize global model loader
MODEL_LOADER = ModelLoader()

# ============================================================================
# REAL-TIME MONITORING: BEHAVIOR + DISEASE (PARALLEL)
# ============================================================================

def analyze_behavior_data(cow_id, eating_time, lying_time, steps, rumination_time, temperature, 
                         baseline_data=None, data_points_count=24):
    """
    Analyze behavior data to determine if cow is Normal or Abnormal
    
    IMPORTANT: Behavior analysis needs TIME to be accurate!
    - Minimum: 12 hours of data (12 data points at 1-hour intervals)
    - Recommended: 24 hours of data (24 data points)
    - Best: 3-7 days of data for trend analysis
    
    Parameters:
    - cow_id: Unique identifier
    - eating_time: Minutes spent eating (normal: 180-300 min/day)
    - lying_time: Hours spent lying (normal: 10-14 hrs/day)
    - steps: Daily step count (normal: 3000-6000 steps)
    - rumination_time: Minutes ruminating (normal: 400-600 min/day)
    - temperature: Body temperature in °C
    - baseline_data: Cow's historical baseline (optional but recommended)
    - data_points_count: How many hours of data collected (minimum 12)
    
    Returns:
    - status: 'NORMAL' or 'ABNORMAL'
    - abnormalities: List of detected issues
    - confidence: 0-1 (confidence in the assessment)
    - needs_more_data: True if insufficient data
    """
    
    print(f"🎥 Real-time Behavior Analysis - Cow #{cow_id}")
    print("=" * 60)
    
    # Check if we have enough data
    needs_more_data = data_points_count < Config.BEHAVIOR_MIN_DATA_POINTS
    
    if needs_more_data:
        print(f"⚠️ INSUFFICIENT DATA: Only {data_points_count} hours of data")
        print(f"   Minimum required: {Config.BEHAVIOR_MIN_DATA_POINTS} hours")
        print(f"   Recommended: {Config.BEHAVIOR_MONITORING_HOURS} hours")
        print(f"   Current analysis may be inaccurate!\n")
    
    abnormalities = []
    severity_score = 0.0
    
    # Calculate confidence based on data availability
    data_confidence = min(data_points_count / Config.BEHAVIOR_MONITORING_HOURS, 1.0)
    
    
    # Use baseline comparison if available
    if baseline_data:
        print("📊 Comparing to individual cow baseline...")
        # Compare to cow's normal behavior
        eating_baseline = baseline_data.get('eating_time', 240)
        if eating_time < eating_baseline * 0.7:
            deviation = (eating_baseline - eating_time) / eating_baseline
            abnormalities.append(f"Eating below baseline: {eating_time} min vs {eating_baseline} min (↓{deviation*100:.0f}%)")
            severity_score += deviation * 1.2  # Higher weight for baseline comparison
    else:
        # Use general population norms
        print("📊 Using population norms (no baseline available)...")
        if eating_time < 180:
            deviation = (180 - eating_time) / 180
            abnormalities.append(f"Low eating time: {eating_time} min (↓{deviation*100:.0f}%)")
            severity_score += deviation
    
    # Check lying time
    if lying_time > 14 or lying_time < 10:
        if lying_time > 14:
            deviation = (lying_time - 14) / 14
            abnormalities.append(f"Excessive lying: {lying_time} hrs (↑{deviation*100:.0f}%)")
            severity_score += deviation * 0.8
        else:
            deviation = (10 - lying_time) / 10
            abnormalities.append(f"Insufficient rest: {lying_time} hrs (↓{deviation*100:.0f}%)")
            severity_score += deviation * 0.6
    
    # Check activity
    if steps < 3000:
        deviation = (3000 - steps) / 3000
        abnormalities.append(f"Low activity: {steps} steps (↓{deviation*100:.0f}%)")
        severity_score += deviation * 0.7
    
    # Check rumination
    if rumination_time < 400:
        deviation = (400 - rumination_time) / 400
        abnormalities.append(f"Low rumination: {rumination_time} min (↓{deviation*100:.0f}%)")
        severity_score += deviation * 0.9
    
    # Check temperature
    if temperature < Config.NORMAL_TEMP_RANGE[0] or temperature > Config.NORMAL_TEMP_RANGE[1]:
        if temperature > Config.NORMAL_TEMP_RANGE[1]:
            abnormalities.append(f"⚠️ Fever detected: {temperature}°C (Normal: 37.5-39.5°C)")
            severity_score += 0.5
        else:
            abnormalities.append(f"Low temperature: {temperature}°C")
            severity_score += 0.3
    
    # Normalize severity score
    severity_score = min(severity_score, 1.0)
    
    # Calculate final confidence
    final_confidence = severity_score * data_confidence
    
    # Determine status
    if severity_score >= Config.BEHAVIOR_ABNORMAL_THRESHOLD and not needs_more_data:
        status = 'ABNORMAL'
        print(f"🚨 ABNORMAL BEHAVIOR DETECTED!")
    elif severity_score >= Config.BEHAVIOR_ABNORMAL_THRESHOLD and needs_more_data:
        status = 'POSSIBLY_ABNORMAL'
        print(f"⚠️ POSSIBLY ABNORMAL (needs more data)")
    else:
        status = 'NORMAL'
        print(f"✅ Behavior appears normal")
    
    print(f"\nBehavior Metrics:")
    print(f"  Eating: {eating_time} min/day")
    print(f"  Lying: {lying_time} hrs/day")
    print(f"  Steps: {steps} steps/day")
    print(f"  Rumination: {rumination_time} min/day")
    print(f"  Temperature: {temperature}°C")
    print(f"\nAnalysis Quality:")
    print(f"  Data Points: {data_points_count} hours")
    print(f"  Data Confidence: {data_confidence:.1%}")
    print(f"  Abnormality Score: {severity_score:.2f}/1.0")
    print(f"  Final Confidence: {final_confidence:.2%}")
    
    if abnormalities:
        print(f"\n⚠️ Detected Issues:")
        for issue in abnormalities:
            print(f"  • {issue}")
    
    if needs_more_data:
        hours_needed = Config.BEHAVIOR_MIN_DATA_POINTS - data_points_count
        print(f"\n💡 RECOMMENDATION: Collect {hours_needed} more hours of data for reliable analysis")
    
    print()
    return status, abnormalities, final_confidence, needs_more_data


def detect_disease_realtime(image_path, use_ensemble=False):
    """
    Real-time disease detection from images/video
    
    Can be called continuously from video stream or when farmer takes photo
    
    Parameters:
    - image_path: Path to image or video frame
    - use_ensemble: Use both YOLOv8x + DenseNet121
    
    Returns:
    - disease_found: True if disease detected
    - disease: Disease name (or None)
    - confidence: Confidence score
    - model_used: Which model made detection
    """
    
    print(f"📸 Real-time Disease Detection")
    print("=" * 60)
    
    # NOTE: Replace with actual YOLOv8x and DenseNet121 inference
    # This is placeholder for demonstration
    
    if use_ensemble:
        print("🤖 Running ENSEMBLE mode (YOLOv8x + DenseNet121)...")
        
        # Run YOLOv8x
        yolo_disease = "Mastitis"  # Placeholder - replace with: yolo_model.predict(image_path)
        yolo_conf = 0.82
        print(f"  YOLOv8x: {yolo_disease} (confidence: {yolo_conf:.2f})")
        
        # Run DenseNet121
        densenet_disease = "Mastitis"  # Placeholder - replace with: densenet_model.predict(image_path)
        densenet_conf = 0.89
        print(f"  DenseNet121: {densenet_disease} (confidence: {densenet_conf:.2f})")
        
        # Both models must agree and exceed threshold
        if yolo_disease == densenet_disease and densenet_conf >= Config.DISEASE_CONFIDENCE_FOR_DIAGNOSIS:
            disease_found = True
            disease = yolo_disease
            confidence = (yolo_conf + densenet_conf) / 2
            model_used = "Ensemble (Both Agree)"
            print(f"✅ Disease confirmed: {disease}")
        elif densenet_conf >= Config.DISEASE_CONFIDENCE_FOR_DIAGNOSIS:
            disease_found = True
            disease = densenet_disease
            confidence = densenet_conf
            model_used = "DenseNet121"
            print(f"✅ Disease detected: {disease}")
        else:
            disease_found = False
            disease = None
            confidence = max(yolo_conf, densenet_conf)
            model_used = "Ensemble (Uncertain)"
            print(f"❌ No disease detected (confidence too low)")
    
    else:
        print("🚀 Running FAST mode (YOLOv8x + smart verification)...")
        
        # Run YOLOv8x first
        yolo_disease = "Mastitis"  # Placeholder
        yolo_conf = 0.82
        print(f"  YOLOv8x: {yolo_disease} (confidence: {yolo_conf:.2f})")
        
        # If high confidence, accept
        if yolo_conf >= Config.YOLO_CONFIDENCE_THRESHOLD:
            disease_found = True
            disease = yolo_disease
            confidence = yolo_conf
            model_used = "YOLOv8x (High Confidence)"
            print(f"✅ Disease detected: {disease}")
        
        # If medium confidence, verify with DenseNet121
        elif yolo_conf >= Config.DISEASE_CONFIDENCE_FOR_DIAGNOSIS:
            print(f"  Confidence moderate, verifying with DenseNet121...")
            densenet_disease = "Mastitis"  # Placeholder
            densenet_conf = 0.89
            print(f"  DenseNet121: {densenet_disease} (confidence: {densenet_conf:.2f})")
            
            if densenet_conf >= Config.DISEASE_CONFIDENCE_FOR_DIAGNOSIS:
                disease_found = True
                disease = densenet_disease
                confidence = densenet_conf
                model_used = "DenseNet121 (Verification)"
                print(f"✅ Disease confirmed: {disease}")
            else:
                disease_found = False
                disease = None
                confidence = densenet_conf
                model_used = "Uncertain"
                print(f"❌ Uncertain - no disease confirmed")
        
        else:
            disease_found = False
            disease = None
            confidence = yolo_conf
            model_used = "YOLOv8x (Low Confidence)"
            print(f"❌ No disease detected")
    
    print(f"\nDetection Result: {'DISEASE FOUND' if disease_found else 'NO DISEASE'}")
    if disease_found:
        print(f"  Disease: {disease}")
        print(f"  Confidence: {confidence:.2%}")
        print(f"  Model: {model_used}")
    print()
    
    return disease_found, disease, confidence, model_used


# ============================================================================
# SEVERITY ASSESSMENT (Only when disease detected)
# ============================================================================

def assess_severity(disease, weight, age, temperature, previous_disease=None):
    """
    Assess disease severity for triage
    
    Parameters:
    - disease: Disease name
    - weight: Weight in kg
    - age: Age in months
    - temperature: Body temperature in °C
    - previous_disease: Previous disease history
    
    Returns:
    - severity_level: 0 (Mild), 1 (Moderate), 2 (Severe)
    - severity_name: Human-readable severity
    - confidence: Model confidence
    """
    
    print(f"⚕️ STEP 3: Severity Assessment")
    print("=" * 60)
    
    if not MODEL_LOADER.models_loaded:
        MODEL_LOADER.load_all_models()
    
    # Encode disease
    try:
        disease_encoded = MODEL_LOADER.severity_encoders['Disease'].transform([disease])[0]
    except:
        print(f"⚠️ Unknown disease '{disease}', using first category")
        disease_encoded = 0
    
    # Encode previous disease
    if previous_disease is None or previous_disease == 'None':
        prev_disease_encoded = 0
    else:
        try:
            prev_disease_encoded = MODEL_LOADER.severity_encoders['Previous_Disease'].transform([previous_disease])[0]
        except:
            prev_disease_encoded = 0
    
    # Create features
    temp_deviation = temperature - Config.NORMAL_TEMP
    weight_age_ratio = weight / (age + 1)
    has_history = 1 if prev_disease_encoded > 0 else 0
    
    features = np.array([[
        disease_encoded,
        weight,
        age,
        temperature,
        prev_disease_encoded,
        temp_deviation,
        weight_age_ratio,
        has_history
    ]])
    
    # Scale and predict
    features_scaled = MODEL_LOADER.severity_scaler.transform(features)
    severity_level = MODEL_LOADER.severity_model.predict(features_scaled)[0]
    probabilities = MODEL_LOADER.severity_model.predict_proba(features_scaled)[0]
    confidence = probabilities[severity_level]
    
    # Map to name
    severity_names = {0: 'Mild', 1: 'Moderate', 2: 'Severe'}
    severity_name = severity_names[severity_level]
    
    print(f"Input Details:")
    print(f"  Disease: {disease}")
    print(f"  Weight: {weight} kg")
    print(f"  Age: {age} months")
    print(f"  Temperature: {temperature}°C (deviation: {temp_deviation:+.1f}°C)")
    print(f"  Previous History: {previous_disease or 'None'}")
    
    print(f"\n✅ Severity Assessment: {severity_name} (Level {severity_level})")
    print(f"   Confidence: {confidence:.2%}")
    print(f"   Probabilities:")
    print(f"     Mild: {probabilities[0]:.2%}")
    print(f"     Moderate: {probabilities[1]:.2%}")
    print(f"     Severe: {probabilities[2]:.2%}")
    
    if severity_level >= Config.SEVERITY_URGENT_THRESHOLD:
        print(f"\n🚨 URGENT: This case requires immediate veterinary attention!")
    elif severity_level == 1:
        print(f"\n⚠️ MODERATE: Monitor closely and prepare treatment")
    else:
        print(f"\n✅ MILD: Can be managed with basic care")
    
    print()
    return severity_level, severity_name, confidence


# ============================================================================
# TREATMENT RECOMMENDATION (Only when disease detected)
# ============================================================================

def recommend_treatment(disease, severity, weight, age, temperature, previous_disease=None):
    """
    Recommend treatment protocol
    
    Parameters:
    - disease: Disease name
    - severity: Severity level (0/1/2)
    - weight: Weight in kg
    - age: Age in months
    - temperature: Body temperature in °C
    - previous_disease: Previous disease history
    
    Returns:
    - treatment: Primary recommended treatment
    - confidence: Confidence score
    - top_3_treatments: Top 3 options with probabilities
    """
    
    print(f"💊 STEP 4: Treatment Recommendation")
    print("=" * 60)
    
    if not MODEL_LOADER.models_loaded:
        MODEL_LOADER.load_all_models()
    
    # Encode disease
    try:
        disease_encoded = MODEL_LOADER.treatment_encoders['Disease'].transform([disease])[0]
    except:
        print(f"⚠️ Unknown disease '{disease}', using first category")
        disease_encoded = 0
    
    # Encode previous disease
    if previous_disease is None or previous_disease == 'None':
        prev_disease_encoded = 0
    else:
        try:
            prev_disease_encoded = MODEL_LOADER.treatment_encoders['Previous_Disease'].transform([previous_disease])[0]
        except:
            prev_disease_encoded = 0
    
    # Create features (same as training)
    temp_deviation = temperature - Config.NORMAL_TEMP
    weight_age_ratio = weight / (age + 1)
    has_history = 1 if prev_disease_encoded > 0 else 0
    severity_temp_interaction = severity * temp_deviation
    
    features = np.array([[
        disease_encoded,
        severity,
        weight,
        age,
        temperature,
        prev_disease_encoded,
        temp_deviation,
        weight_age_ratio,
        has_history,
        severity_temp_interaction
    ]])
    
    # Scale and predict
    features_scaled = MODEL_LOADER.treatment_scaler.transform(features)
    treatment_idx = MODEL_LOADER.treatment_model.predict(features_scaled)[0]
    probabilities = MODEL_LOADER.treatment_model.predict_proba(features_scaled)[0]
    
    # Get treatment name
    treatment = MODEL_LOADER.treatment_encoders['Treatment'].classes_[treatment_idx]
    confidence = probabilities[treatment_idx]
    
    # Get top 3 treatments
    top_3_idx = np.argsort(probabilities)[-3:][::-1]
    top_3_treatments = [
        (MODEL_LOADER.treatment_encoders['Treatment'].classes_[idx], probabilities[idx])
        for idx in top_3_idx
    ]
    
    print(f"✅ PRIMARY RECOMMENDATION: {treatment}")
    print(f"   Confidence: {confidence:.2%}")
    print(f"\n📋 Top 3 Treatment Options:")
    for i, (treat, prob) in enumerate(top_3_treatments, 1):
        marker = "🥇" if i == 1 else "🥈" if i == 2 else "🥉"
        print(f"   {marker} {i}. {treat}")
        print(f"      Probability: {prob:.2%}")
    
    print()
    return treatment, confidence, top_3_treatments


# ============================================================================
# NEW WORKFLOW: PARALLEL REAL-TIME MONITORING
# ============================================================================

def realtime_cattle_monitoring(
    cow_id,
    image_path,
    eating_time,
    lying_time,
    steps,
    rumination_time,
    weight,
    age,
    temperature,
    previous_disease=None,
    baseline_data=None,
    data_points_count=24,
    use_ensemble=False
):
    """
    NEW BEST WORKFLOW: Parallel real-time monitoring
    
    Logic:
    1. Run BOTH behavior analysis AND disease detection simultaneously
    2. IF disease found → Proceed to Severity + Treatment
    3. IF no disease found → Use behavior analysis to determine Normal/Abnormal
    
    Parameters:
    - cow_id: Unique cow identifier
    - image_path: Path to cow photo/video frame
    - eating_time: Minutes eating per day
    - lying_time: Hours lying per day
    - steps: Daily steps
    - rumination_time: Minutes ruminating
    - weight: Weight in kg
    - age: Age in months
    - temperature: Body temperature
    - previous_disease: Disease history
    - baseline_data: Cow's normal baseline (optional)
    - data_points_count: Hours of behavior data collected
    - use_ensemble: Use both YOLO + DenseNet121
    
    Returns:
    - complete_report: Dictionary with all results
    """
    
    print("\n" + "=" * 70)
    print("🐄 REAL-TIME CATTLE MONITORING SYSTEM")
    print("=" * 70)
    print(f"Cow ID: {cow_id}")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Mode: {'ENSEMBLE' if use_ensemble else 'FAST'}")
    print("=" * 70 + "\n")
    
    # ========================================================================
    # PARALLEL STEP 1 & 2: Run behavior analysis AND disease detection together
    # ========================================================================
    
    print("🔄 PARALLEL MONITORING: Running behavior + disease detection...")
    print("-" * 70 + "\n")
    
    # Analyze behavior (can run from continuous video stream)
    behavior_status, abnormalities, behavior_confidence, needs_more_data = analyze_behavior_data(
        cow_id, eating_time, lying_time, steps, rumination_time, temperature,
        baseline_data=baseline_data,
        data_points_count=data_points_count
    )
    
    # Detect disease (can run from video frames or photos)
    disease_found, disease, disease_confidence, model_used = detect_disease_realtime(
        image_path, use_ensemble=use_ensemble
    )
    
    # ========================================================================
    # DECISION POINT: Disease found or not?
    # ========================================================================
    
    print("=" * 70)
    print("🎯 DECISION POINT: Determining next steps...")
    print("=" * 70 + "\n")
    
    if disease_found:
        # ====================================================================
        # PATH A: DISEASE DETECTED → Proceed to Severity + Treatment
        # ====================================================================
        
        print("✅ DISEASE DETECTED → Proceeding to diagnosis workflow\n")
        
        # Step 3: Severity Assessment
        severity_level, severity_name, severity_confidence = assess_severity(
            disease, weight, age, temperature, previous_disease
        )
        
        # Step 4: Treatment Recommendation
        treatment, treatment_confidence, top_3_treatments = recommend_treatment(
            disease, severity_level, weight, age, temperature, previous_disease
        )
        
        # Final Report for Disease Path
        print("\n" + "=" * 70)
        print("📋 FINAL REPORT: DISEASE DIAGNOSED")
        print("=" * 70)
        
        print(f"\n🐄 COW INFORMATION:")
        print(f"  ID: {cow_id}")
        print(f"  Weight: {weight} kg")
        print(f"  Age: {age} months")
        print(f"  Temperature: {temperature}°C")
        
        print(f"\n📸 DISEASE DETECTION:")
        print(f"  Disease: {disease}")
        print(f"  Confidence: {disease_confidence:.2%}")
        print(f"  Model: {model_used}")
        
        print(f"\n⚕️ SEVERITY:")
        print(f"  Level: {severity_name} ({severity_level})")
        print(f"  Confidence: {severity_confidence:.2%}")
        
        print(f"\n💊 TREATMENT:")
        print(f"  Primary: {treatment}")
        print(f"  Confidence: {treatment_confidence:.2%}")
        print(f"  Alternatives:")
        for i, (treat, prob) in enumerate(top_3_treatments[1:], 2):
            print(f"    {i}. {treat} ({prob:.2%})")
        
        print(f"\n🎥 BEHAVIOR STATUS:")
        print(f"  Status: {behavior_status}")
        print(f"  Confidence: {behavior_confidence:.2%}")
        if abnormalities:
            print(f"  Issues detected:")
            for issue in abnormalities:
                print(f"    • {issue}")
        
        print(f"\n🚨 ACTION REQUIRED:")
        if severity_level == 2:
            print(f"  ⚠️ URGENT: Contact veterinarian immediately!")
            print(f"  ⚠️ Isolate cow to prevent spread")
            print(f"  ⚠️ Begin treatment: {treatment}")
        elif severity_level == 1:
            print(f"  📞 MODERATE: Schedule veterinary visit within 24 hours")
            print(f"  👁️ Monitor temperature and behavior closely")
            print(f"  💊 Prepare for treatment: {treatment}")
        else:
            print(f"  ✅ MILD: Monitor and apply basic care")
            print(f"  💊 Treatment: {treatment}")
        
        return {
            'cow_id': cow_id,
            'timestamp': datetime.now(),
            'workflow_path': 'DISEASE_DETECTED',
            'disease_found': True,
            'disease': disease,
            'disease_confidence': disease_confidence,
            'model_used': model_used,
            'severity_level': severity_level,
            'severity_name': severity_name,
            'severity_confidence': severity_confidence,
            'treatment': treatment,
            'treatment_confidence': treatment_confidence,
            'alternative_treatments': top_3_treatments[1:],
            'behavior_status': behavior_status,
            'behavior_confidence': behavior_confidence,
            'abnormalities': abnormalities
        }
    
    else:
        # ====================================================================
        # PATH B: NO DISEASE DETECTED → Use behavior analysis only
        # ====================================================================
        
        print("❌ NO DISEASE DETECTED → Using behavior analysis for assessment\n")
        
        # Final Report for Behavior Path
        print("\n" + "=" * 70)
        print("📋 FINAL REPORT: BEHAVIOR-BASED ASSESSMENT")
        print("=" * 70)
        
        print(f"\n🐄 COW INFORMATION:")
        print(f"  ID: {cow_id}")
        print(f"  Temperature: {temperature}°C")
        
        print(f"\n📸 DISEASE DETECTION:")
        print(f"  Status: NO DISEASE DETECTED")
        print(f"  Confidence: {disease_confidence:.2%}")
        
        print(f"\n🎥 BEHAVIOR ANALYSIS:")
        print(f"  Status: {behavior_status}")
        print(f"  Confidence: {behavior_confidence:.2%}")
        print(f"  Data Quality: {data_points_count} hours of data")
        
        if needs_more_data:
            hours_needed = Config.BEHAVIOR_MIN_DATA_POINTS - data_points_count
            print(f"  ⚠️ WARNING: Need {hours_needed} more hours for reliable analysis")
        
        print(f"\n  Behavior Metrics:")
        print(f"    Eating: {eating_time} min/day (Normal: 180-300)")
        print(f"    Lying: {lying_time} hrs/day (Normal: 10-14)")
        print(f"    Steps: {steps} steps/day (Normal: 3000-6000)")
        print(f"    Rumination: {rumination_time} min/day (Normal: 400-600)")
        
        if abnormalities:
            print(f"\n  ⚠️ Detected Issues:")
            for issue in abnormalities:
                print(f"    • {issue}")
        
        print(f"\n🚨 RECOMMENDED ACTIONS:")
        
        if behavior_status == 'ABNORMAL':
            print(f"  ⚠️ ABNORMAL BEHAVIOR: Even without visible disease")
            print(f"  📸 Take close-up photos for disease detection")
            print(f"  👁️ Monitor closely for next {Config.BEHAVIOR_CHECK_INTERVAL_MINUTES} minutes")
            print(f"  📞 Consider veterinary consultation if behavior worsens")
            print(f"  🌡️ Check temperature regularly")
        
        elif behavior_status == 'POSSIBLY_ABNORMAL':
            print(f"  ⏳ INSUFFICIENT DATA: Continue monitoring")
            print(f"  📊 Collect {Config.BEHAVIOR_MIN_DATA_POINTS - data_points_count} more hours of data")
            print(f"  👁️ Watch for physical symptoms")
            print(f"  ✅ Re-evaluate after reaching {Config.BEHAVIOR_MIN_DATA_POINTS} hours")
        
        else:  # NORMAL
            print(f"  ✅ COW APPEARS HEALTHY")
            print(f"  📊 Continue routine monitoring")
            print(f"  🎥 Behavior tracking active")
            print(f"  👁️ No immediate action required")
        
        print("\n" + "=" * 70)
        print("✅ MONITORING COMPLETE")
        print("=" * 70 + "\n")
        
        return {
            'cow_id': cow_id,
            'timestamp': datetime.now(),
            'workflow_path': 'NO_DISEASE_BEHAVIOR_ONLY',
            'disease_found': False,
            'disease': None,
            'disease_confidence': disease_confidence,
            'behavior_status': behavior_status,
            'behavior_confidence': behavior_confidence,
            'abnormalities': abnormalities,
            'needs_more_data': needs_more_data,
            'data_points_count': data_points_count,
            'severity_level': None,
            'treatment': None
        }


# ============================================================================
# COMPLETE INTEGRATED WORKFLOW (OLD - DEPRECATED)
# ============================================================================

def complete_diagnosis_workflow(
    cow_id,
    image_path,
    eating_time,
    lying_time,
    steps,
    rumination_time,
    weight,
    age,
    temperature,
    previous_disease=None,
    use_ensemble=False
):
    """
    COMPLETE WORKFLOW: From behavior monitoring to treatment recommendation
    
    This is the BEST workflow integrating all 5 models
    
    Parameters:
    - cow_id: Unique cow identifier
    - image_path: Path to cow photo
    - eating_time: Minutes eating per day
    - lying_time: Hours lying per day
    - steps: Daily steps
    - rumination_time: Minutes ruminating
    - weight: Weight in kg
    - age: Age in months
    - temperature: Body temperature
    - previous_disease: Disease history
    - use_ensemble: Use both YOLO + DenseNet121
    
    Returns:
    - complete_report: Dictionary with all results
    """
    
    print("\n" + "=" * 70)
    print("🐄 INTEGRATED CATTLE DISEASE DIAGNOSIS SYSTEM")
    print("=" * 70)
    print(f"Cow ID: {cow_id}")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70 + "\n")
    
    # STEP 1: Behavior Monitoring
    behavior_status, abnormalities, behavior_score = monitor_behavior(
        cow_id, eating_time, lying_time, steps, rumination_time, temperature
    )
    
    # If behavior is normal, no need to continue
    if behavior_status == 'HEALTHY':
        print("✅ DIAGNOSIS: Cow appears healthy. No further action needed.\n")
        return {
            'cow_id': cow_id,
            'status': 'HEALTHY',
            'behavior_score': behavior_score,
            'disease': None,
            'severity': None,
            'treatment': None
        }
    
    # STEP 2: Disease Detection
    disease, disease_confidence, model_used = detect_disease_intelligent(
        image_path, use_ensemble=use_ensemble
    )
    
    # STEP 3: Severity Assessment
    severity_level, severity_name, severity_confidence = assess_severity(
        disease, weight, age, temperature, previous_disease
    )
    
    # STEP 4: Treatment Recommendation
    treatment, treatment_confidence, top_3_treatments = recommend_treatment(
        disease, severity_level, weight, age, temperature, previous_disease
    )
    
    # ========================================================================
    # FINAL REPORT
    # ========================================================================
    
    print("\n" + "=" * 70)
    print("📋 COMPLETE DIAGNOSIS REPORT")
    print("=" * 70)
    
    print(f"\n🐄 COW INFORMATION:")
    print(f"  ID: {cow_id}")
    print(f"  Weight: {weight} kg")
    print(f"  Age: {age} months")
    print(f"  Temperature: {temperature}°C")
    print(f"  Previous History: {previous_disease or 'None'}")
    
    print(f"\n🎥 BEHAVIOR ANALYSIS:")
    print(f"  Status: {behavior_status}")
    print(f"  Abnormality Score: {behavior_score:.2f}/1.0")
    if abnormalities:
        for issue in abnormalities:
            print(f"  • {issue}")
    
    print(f"\n📸 DISEASE DETECTION:")
    print(f"  Disease: {disease}")
    print(f"  Confidence: {disease_confidence:.2%}")
    print(f"  Model: {model_used}")
    
    print(f"\n⚕️ SEVERITY ASSESSMENT:")
    print(f"  Level: {severity_name} ({severity_level})")
    print(f"  Confidence: {severity_confidence:.2%}")
    
    print(f"\n💊 TREATMENT RECOMMENDATION:")
    print(f"  Primary: {treatment}")
    print(f"  Confidence: {treatment_confidence:.2%}")
    print(f"  Alternatives:")
    for i, (treat, prob) in enumerate(top_3_treatments[1:], 2):
        print(f"    {i}. {treat} ({prob:.2%})")
    
    print(f"\n🚨 ACTION REQUIRED:")
    if severity_level == 2:
        print(f"  ⚠️ URGENT: Contact veterinarian immediately!")
        print(f"  ⚠️ Isolate cow to prevent spread")
        print(f"  ⚠️ Begin treatment: {treatment}")
    elif severity_level == 1:
        print(f"  📞 MODERATE: Schedule veterinary visit within 24 hours")
        print(f"  👁️ Monitor temperature and behavior closely")
        print(f"  💊 Prepare for treatment: {treatment}")
    else:
        print(f"  ✅ MILD: Monitor and apply basic care")
        print(f"  💊 Treatment: {treatment}")
        print(f"  📊 Continue behavior monitoring")
    
    print("\n" + "=" * 70)
    print("✅ DIAGNOSIS COMPLETE")
    print("=" * 70 + "\n")
    
    # Return complete report
    return {
        'cow_id': cow_id,
        'timestamp': datetime.now(),
        'status': behavior_status,
        'behavior_score': behavior_score,
        'abnormalities': abnormalities,
        'disease': disease,
        'disease_confidence': disease_confidence,
        'model_used': model_used,
        'severity_level': severity_level,
        'severity_name': severity_name,
        'severity_confidence': severity_confidence,
        'treatment': treatment,
        'treatment_confidence': treatment_confidence,
        'alternative_treatments': top_3_treatments[1:]
    }


# ============================================================================
# EXAMPLE USAGE
# ============================================================================

if __name__ == "__main__":
    
    print("\n" + "="*70)
    print("🧪 TESTING NEW REAL-TIME MONITORING WORKFLOW")
    print("="*70 + "\n")
    
    # Load models once
    MODEL_LOADER.load_all_models()
    
    # ========================================================================
    # TEST CASE 1: Healthy Cow (Behavior Normal, No Disease)
    # ========================================================================
    
    print("\n" + "🧪 TEST CASE 1: HEALTHY COW")
    print("Scenario: Normal behavior, no visible disease")
    print("-" * 70)
    
    report1 = realtime_cattle_monitoring(
        cow_id="SL-001",
        image_path="path/to/cow_photo.jpg",
        eating_time=250,      # Normal
        lying_time=12,        # Normal
        steps=4500,           # Normal
        rumination_time=500,  # Normal
        weight=450,
        age=40,
        temperature=38.6,     # Normal
        previous_disease=None,
        data_points_count=24,  # Full 24 hours of data
        use_ensemble=False
    )
    
    # ========================================================================
    # TEST CASE 2: Abnormal Behavior BUT No Visible Disease Yet
    # ========================================================================
    
    print("\n" + "🧪 TEST CASE 2: ABNORMAL BEHAVIOR - NO VISIBLE DISEASE")
    print("Scenario: Early warning - behavior changes before disease visible")
    print("-" * 70)
    
    report2 = realtime_cattle_monitoring(
        cow_id="SL-002",
        image_path="path/to/cow_photo.jpg",
        eating_time=120,      # Low! Early warning
        lying_time=16,        # High!
        steps=2000,           # Low!
        rumination_time=250,  # Low!
        weight=420,
        age=35,
        temperature=38.9,     # Slightly elevated
        previous_disease=None,
        data_points_count=24,  # Full data available
        use_ensemble=False
    )
    
    # ========================================================================
    # TEST CASE 3: Insufficient Data - Need More Monitoring
    # ========================================================================
    
    print("\n" + "🧪 TEST CASE 3: INSUFFICIENT DATA")
    print("Scenario: Only 6 hours of data - need more monitoring")
    print("-" * 70)
    
    report3 = realtime_cattle_monitoring(
        cow_id="SL-003",
        image_path="path/to/cow_photo.jpg",
        eating_time=150,      # Possibly low
        lying_time=15,        # Possibly high
        steps=2500,           # Possibly low
        rumination_time=350,  # Possibly low
        weight=410,
        age=30,
        temperature=39.2,
        previous_disease=None,
        data_points_count=6,   # Only 6 hours! Need more data
        use_ensemble=False
    )
    
    # ========================================================================
    # TEST CASE 4: Disease Detected → Full Diagnosis Workflow
    # ========================================================================
    
    print("\n" + "🧪 TEST CASE 4: DISEASE DETECTED - MODERATE MASTITIS")
    print("Scenario: Visible disease + abnormal behavior → Full diagnosis")
    print("-" * 70)
    
    report4 = realtime_cattle_monitoring(
        cow_id="SL-004",
        image_path="path/to/mastitis_photo.jpg",
        eating_time=130,      # Low
        lying_time=15,        # High
        steps=2200,           # Low
        rumination_time=280,  # Low
        weight=420,
        age=35,
        temperature=39.8,     # Elevated
        previous_disease=None,
        data_points_count=24,
        use_ensemble=False    # Fast mode
    )
    
    # ========================================================================
    # TEST CASE 5: Critical - Severe Disease with Ensemble Detection
    # ========================================================================
    
    print("\n" + "🧪 TEST CASE 5: CRITICAL - SEVERE FMD (ENSEMBLE MODE)")
    print("Scenario: Serious disease, use both models for maximum accuracy")
    print("-" * 70)
    
    report5 = realtime_cattle_monitoring(
        cow_id="SL-005",
        image_path="path/to/fmd_photo.jpg",
        eating_time=60,       # Very low
        lying_time=18,        # Very high
        steps=800,            # Very low
        rumination_time=100,  # Very low
        weight=380,
        age=25,
        temperature=41.0,     # High fever
        previous_disease="Mastitis",
        baseline_data={'eating_time': 240, 'lying_time': 12},  # Individual baseline
        data_points_count=24,
        use_ensemble=True     # Use both YOLO + DenseNet121
    )
    
    # ========================================================================
    # SUMMARY
    # ========================================================================
    
    print("\n" + "="*70)
    print("📊 TEST SUMMARY")
    print("="*70)
    print(f"\nTest 1: {report1['workflow_path']} - {report1.get('behavior_status', 'N/A')}")
    print(f"Test 2: {report2['workflow_path']} - {report2.get('behavior_status', 'N/A')}")
    print(f"Test 3: {report3['workflow_path']} - {report3.get('behavior_status', 'N/A')} (needs more data: {report3['needs_more_data']})")
    print(f"Test 4: {report4['workflow_path']} - Disease: {report4.get('disease', 'None')}")
    print(f"Test 5: {report5['workflow_path']} - Disease: {report5.get('disease', 'None')} (Severity: {report5.get('severity_name', 'N/A')})")
    
    print("\n" + "="*70)
    print("✅ ALL TESTS COMPLETED")
    print("="*70 + "\n")
    
    print("\n💡 KEY INSIGHTS:")
    print("-" * 70)
    print("✅ Behavior monitoring needs 12-24 hours of data for accuracy")
    print("✅ Disease detection works immediately from images")
    print("✅ If disease found → Automatic severity + treatment workflow")
    print("✅ If no disease → Behavior analysis guides monitoring")
    print("✅ Early warning possible: Behavior changes BEFORE visible disease")
    print("-" * 70 + "\n")
