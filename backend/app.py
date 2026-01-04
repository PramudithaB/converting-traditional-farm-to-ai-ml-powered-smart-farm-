"""
Unified Smart Farm Backend API
Consolidates all AI/ML services into a single Flask application
Including: Animal Birth, Cow ID, Feed, Egg Hatch, Milk Market, Nutrition, and Cattle Disease Detection
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from tensorflow.keras import backend as K
from tensorflow import keras
from ultralytics import YOLO
from PIL import Image
import cv2
import os
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend communication

# ==================== Global Configuration ====================
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Import behavior system if available
try:
    import sys
    sys.path.append(os.path.join(os.path.dirname(__file__), 'cattle_disease_detection'))
    from behavior_data_manager import BehaviorDataCollector, BehaviorAnalyzer
    BEHAVIOR_AVAILABLE = True
except ImportError:
    BEHAVIOR_AVAILABLE = False
    print("⚠️ Behavior system not available")

# Cattle Disease Configuration
class CattleDiseaseConfig:
    """Cattle Disease Detection Configuration"""
    DENSENET_MODEL = "cattle_disease_detection/models/DenseNet121_Disease/best_model.h5"
    YOLO_DISEASE_MODEL = "cattle_disease_detection/models/All_Cattle_Disease/best.pt"
    YOLO_BEHAVIOR_MODEL = "cattle_disease_detection/models/All_Behaviore/best.pt"
    
    SEVERITY_MODEL = "cattle_disease_detection/models/Treatment_Severity/best_model_gradient_boosting.pkl"
    SEVERITY_SCALER = "cattle_disease_detection/models/Treatment_Severity/scaler.pkl"
    SEVERITY_ENCODERS = "cattle_disease_detection/models/Treatment_Severity/label_encoders.pkl"
    
    TREATMENT_MODEL = "cattle_disease_detection/models/Treatment_Recommendation/best_model_gradient_boosting.pkl"
    TREATMENT_SCALER = "cattle_disease_detection/models/Treatment_Recommendation/scaler.pkl"
    TREATMENT_ENCODERS = "cattle_disease_detection/models/Treatment_Recommendation/label_encoders.pkl"
    
    IMG_SIZE = (224, 224)
    ALLOWED_VIDEO_EXTENSIONS = {'mp4', 'avi', 'mov', 'mkv', 'webm'}
    
    DISEASE_CLASSES = [
        'Contagious', 'Dermatophilosis', 'FMD', 'Healthy',
        'Lumpy Skin', 'Mastitis', 'Pediculosis', 'Ringworm'
    ]
    
    SEVERITY_CLASSES = ['Mild', 'Moderate', 'Severe']

# ==================== Animal Birth Models ====================
try:
    animal_birth_model = joblib.load("animal_birth/clf.pkl")
    print("✓ Animal Birth model loaded")
except Exception as e:
    print(f"✗ Animal Birth model failed: {e}")
    animal_birth_model = None

# ==================== Cow Identification Models ====================
try:
    cow_identify_model = YOLO("cow_identify/best.pt")
    print("✓ Cow Identification model loaded")
except Exception as e:
    print(f"✗ Cow Identification model failed: {e}")
    cow_identify_model = None

# ==================== Egg Hatch Models ====================
try:
    egg_hatch_scaler = joblib.load("egg_hatch/egg_hatch_scaler.joblib")
    egg_hatch_nn_model = tf.keras.models.load_model("egg_hatch/egg_hatch_nn.h5")
    print("✓ Egg Hatch models loaded")
except Exception as e:
    print(f"✗ Egg Hatch models failed: {e}")
    egg_hatch_scaler = None
    egg_hatch_nn_model = None

# ==================== Milk Market Models ====================
try:
    milk_market_model = joblib.load("milk_market_prediction/rf_milk_price_model.pkl")
    print("✓ Milk Market model loaded")
except Exception as e:
    print(f"✗ Milk Market model failed: {e}")
    milk_market_model = None

# ==================== Nutrition Models ====================
try:
    nutrition_model = joblib.load("nutrition_recommended/multi_output_nutrition_model.pkl")
    print("✓ Nutrition model loaded")
except Exception as e:
    print(f"✗ Nutrition model failed: {e}")
    print("⚠️  Note: If you see sklearn version errors, the model may need to be retrained with your current sklearn version")
    print("⚠️  Run: pip install scikit-learn==1.6.1  OR retrain the model")
    nutrition_model = None

# ==================== Cow Daily Feed Models ====================
def dice_coef(y_true, y_pred, smooth=1e-6):
    y_true_f = K.flatten(y_true)
    y_pred_f = K.flatten(y_pred)
    intersection = K.sum(y_true_f * y_pred_f)
    return (2. * intersection + smooth) / (K.sum(y_true_f) + K.sum(y_pred_f) + smooth)

try:
    cow_feed_seg_model = load_model(
        "cow_daily_feed/models/best_seg_model.h5",
        custom_objects={"dice_coef": dice_coef}
    )
    cow_feed_reg_model = load_model("cow_daily_feed/models/best_reg_model.h5", compile=False)
    cow_feed_model = joblib.load("cow_daily_feed/models/cow_feed_predictor.pkl")
    cow_feed_breed_encoder = joblib.load("cow_daily_feed/models/breed_encoder.pkl")
    cow_feed_activity_encoder = joblib.load("cow_daily_feed/models/activity_encoder.pkl")
    print("✓ Cow Daily Feed models loaded")
except Exception as e:
    print(f"✗ Cow Daily Feed models failed: {e}")
    cow_feed_seg_model = None
    cow_feed_reg_model = None
    cow_feed_model = None
    cow_feed_breed_encoder = None
    cow_feed_activity_encoder = None

IMG_SIZE = (224, 224)

# ==================== Cattle Disease Detection Models ====================
print("\n🐄 Loading Cattle Disease Detection Models...")

# DenseNet121 for disease classification
try:
    cattle_densenet_model = keras.models.load_model(CattleDiseaseConfig.DENSENET_MODEL)
    print("✓ Cattle DenseNet121 model loaded")
except Exception as e:
    print(f"✗ Cattle DenseNet121 failed: {e}")
    cattle_densenet_model = None

# YOLO models for disease and behavior
try:
    cattle_yolo_disease_model = YOLO(CattleDiseaseConfig.YOLO_DISEASE_MODEL)
    print("✓ Cattle YOLO Disease model loaded")
except Exception as e:
    print(f"✗ Cattle YOLO Disease failed: {e}")
    cattle_yolo_disease_model = None

try:
    cattle_yolo_behavior_model = YOLO(CattleDiseaseConfig.YOLO_BEHAVIOR_MODEL)
    print("✓ Cattle YOLO Behavior model loaded")
except Exception as e:
    print(f"✗ Cattle YOLO Behavior failed: {e}")
    cattle_yolo_behavior_model = None

# Severity prediction model
try:
    cattle_severity_model = joblib.load(CattleDiseaseConfig.SEVERITY_MODEL)
    cattle_severity_scaler = joblib.load(CattleDiseaseConfig.SEVERITY_SCALER)
    cattle_severity_encoders = joblib.load(CattleDiseaseConfig.SEVERITY_ENCODERS)
    print("✓ Cattle Severity model loaded")
except Exception as e:
    print(f"✗ Cattle Severity model failed: {e}")
    cattle_severity_model = None
    cattle_severity_scaler = None
    cattle_severity_encoders = None

# Treatment recommendation model
try:
    cattle_treatment_model = joblib.load(CattleDiseaseConfig.TREATMENT_MODEL)
    cattle_treatment_scaler = joblib.load(CattleDiseaseConfig.TREATMENT_SCALER)
    cattle_treatment_encoders = joblib.load(CattleDiseaseConfig.TREATMENT_ENCODERS)
    print("✓ Cattle Treatment model loaded")
except Exception as e:
    print(f"✗ Cattle Treatment model failed: {e}")
    cattle_treatment_model = None
    cattle_treatment_scaler = None
    cattle_treatment_encoders = None

# Behavior tracking system
try:
    if BEHAVIOR_AVAILABLE:
        cattle_behavior_collector = BehaviorDataCollector()
        cattle_behavior_analyzer = BehaviorAnalyzer(cattle_behavior_collector)
        print("✓ Cattle Behavior system loaded")
    else:
        cattle_behavior_collector = None
        cattle_behavior_analyzer = None
except Exception as e:
    print(f"✗ Cattle Behavior system failed: {e}")
    cattle_behavior_collector = None
    cattle_behavior_analyzer = None

# ==================== Helper Functions ====================
def process_image(img_path):
    img = image.load_img(img_path, target_size=IMG_SIZE)
    img_array = image.img_to_array(img) / 255.0
    return np.expand_dims(img_array, axis=0)

def process_image_for_cattle_densenet(img_path):
    """Process image for Cattle DenseNet121"""
    img = cv2.imread(img_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, CattleDiseaseConfig.IMG_SIZE)
    img_array = np.expand_dims(img, axis=0)
    img_array = img_array / 255.0
    return img_array

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg'}

def allowed_video_file(filename):
    """Check if video file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in CattleDiseaseConfig.ALLOWED_VIDEO_EXTENSIONS

def save_uploaded_file(file):
    """Save uploaded file and return path"""
    if file and allowed_file(file.filename):
        filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{file.filename}"
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        file.save(filepath)
        return filepath
    return None

def save_uploaded_video(file):
    """Save uploaded video file and return path"""
    if file and allowed_video_file(file.filename):
        filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{file.filename}"
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        file.save(filepath)
        return filepath
    return None

def process_video_frames(video_path, frame_interval=30):
    """Extract frames from video at specified interval"""
    frames = []
    cap = cv2.VideoCapture(video_path)
    
    if not cap.isOpened():
        return None
    
    frame_count = 0
    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        if frame_count % frame_interval == 0:
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frames.append(frame_rgb)
        
        frame_count += 1
    
    cap.release()
    
    return {
        'frames': frames,
        'total_frames': total_frames,
        'fps': fps,
        'duration': total_frames / fps if fps > 0 else 0,
        'extracted_frames': len(frames)
    }

# ==================== Root Endpoint ====================
@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "message": "Smart Farm AI Backend - Unified API",
        "version": "2.0.0",
        "endpoints": {
            "animal_birth": "/animal-birth/predict",
            "cow_identification": "/cow-identify/detect",
            "cow_feed_image": "/cow-feed/predict-from-image",
            "cow_feed_manual": "/cow-feed/predict-manual",
            "egg_hatch": "/egg-hatch/predict",
            "milk_market": "/milk-market/predict-income",
            "nutrition": "/nutrition/predict",
            "cattle_disease": {
                "health": "/api/health",
                "models_status": "/api/models/status",
                "disease_detect": "/api/disease/detect",
                "complete_analysis": "/api/disease/analyze",
                "quick_diagnosis": "/api/quick-diagnosis",
                "behavior_snapshot": "/api/behavior/snapshot",
                "behavior_analyze": "/api/behavior/analyze/<cow_id>",
                "behavior_detect_video": "/api/behavior/detect-from-video",
                "video_analyze": "/api/video/analyze"
            }
        },
        "status": "running"
    })

@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "services": {
            "animal_birth": animal_birth_model is not None,
            "cow_identify": cow_identify_model is not None,
            "egg_hatch": egg_hatch_nn_model is not None,
            "milk_market": milk_market_model is not None,
            "nutrition": nutrition_model is not None,
            "cow_feed": cow_feed_model is not None,
            "cattle_disease_detection": cattle_densenet_model is not None,
            "cattle_disease_yolo": cattle_yolo_disease_model is not None,
            "cattle_behavior": cattle_yolo_behavior_model is not None
        }
    })

# ==================== Animal Birth Prediction ====================
@app.route("/animal-birth/predict", methods=["POST"])
def predict_animal_birth():
    if animal_birth_model is None:
        return jsonify({"error": "Animal birth model not loaded"}), 503
    
    try:
        data = request.get_json()
        features = np.array(data["features"]).reshape(1, -1)
        predicted_days = float(animal_birth_model.predict(features)[0])
        will_birth_2_days = "Yes" if predicted_days <= 2 else "No"
        
        return jsonify({
            "Will Birth in Next 2 Days": will_birth_2_days,
            "Estimated Days to Birth": round(predicted_days, 1)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# ==================== Cow Identification ====================
@app.route("/cow-identify/detect", methods=["POST"])
def detect_cow():
    if cow_identify_model is None:
        return jsonify({"error": "Cow identification model not loaded"}), 503
    
    if "image" not in request.files:
        return jsonify({"error": "No image file provided"}), 400
    
    try:
        file = request.files["image"]
        pil_image = Image.open(file).convert("RGB")
        image_np = np.array(pil_image)
        results = cow_identify_model.predict(source=image_np, conf=0.25)
        
        names = cow_identify_model.names
        detected_classes = []
        
        for r in results:
            if r.boxes is not None:
                for c in r.boxes.cls:
                    detected_classes.append(names[int(c)])
        
        detected_classes = list(set(detected_classes))
        
        return jsonify({
            "detected": len(detected_classes) > 0,
            "cow_ids": detected_classes
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ==================== Cow Daily Feed (From Image) ====================
@app.route("/cow-feed/predict-from-image", methods=["POST"])
def predict_cow_feed_from_image():
    if cow_feed_model is None:
        return jsonify({"error": "Cow feed model not loaded"}), 503
    
    try:
        img_file = request.files["image"]
        img_path = os.path.join(UPLOAD_FOLDER, "temp_feed.jpg")
        img_file.save(img_path)
        
        cow_breed = request.form.get("breed").strip().title()
        cow_age = float(request.form.get("age"))
        milk_yield = float(request.form.get("milk_yield"))
        activity = request.form.get("activity").strip().title()
        
        # Validate
        if cow_breed not in cow_feed_breed_encoder.classes_:
            return jsonify({
                "error": f"Invalid breed. Allowed: {list(cow_feed_breed_encoder.classes_)}"
            }), 400
        
        if activity not in cow_feed_activity_encoder.classes_:
            return jsonify({
                "error": f"Invalid activity. Allowed: {list(cow_feed_activity_encoder.classes_)}"
            }), 400
        
        # Encode
        encoded_breed = cow_feed_breed_encoder.transform([cow_breed])[0]
        encoded_activity = cow_feed_activity_encoder.transform([activity])[0]
        
        # Segmentation
        input_image = process_image(img_path)
        predicted_mask = cow_feed_seg_model.predict(input_image)
        predicted_mask = predicted_mask[..., :1]
        
        # Weight prediction
        predicted_weight = cow_feed_reg_model.predict(predicted_mask)
        cow_weight = float(predicted_weight[0][0])
        
        # Feed prediction
        feed_input = pd.DataFrame([{
            "Cow Breed": encoded_breed,
            "Cow Age (months)": cow_age,
            "Cow Weight (kg)": cow_weight,
            "Milk Yield (L/day)": milk_yield,
            "Activity Level": encoded_activity
        }])
        
        daily_feed = float(cow_feed_model.predict(feed_input)[0])
        
        os.remove(img_path)
        
        return jsonify({
            "mode": "image",
            "cow_weight_kg": round(cow_weight, 2),
            "daily_feed_kg": round(daily_feed, 2)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ==================== Cow Daily Feed (Manual) ====================
@app.route("/cow-feed/predict-manual", methods=["POST"])
def predict_cow_feed_manual():
    if cow_feed_model is None:
        return jsonify({"error": "Cow feed model not loaded"}), 503
    
    try:
        data = request.get_json()
        
        cow_breed = data["breed"].strip().title()
        cow_age = float(data["age"])
        cow_weight = float(data["weight"])
        milk_yield = float(data["milk_yield"])
        activity = data["activity"].strip().title()
        
        # Validate
        if cow_breed not in cow_feed_breed_encoder.classes_:
            return jsonify({
                "error": f"Invalid breed. Allowed: {list(cow_feed_breed_encoder.classes_)}"
            }), 400
        
        if activity not in cow_feed_activity_encoder.classes_:
            return jsonify({
                "error": f"Invalid activity. Allowed: {list(cow_feed_activity_encoder.classes_)}"
            }), 400
        
        # Encode
        encoded_breed = cow_feed_breed_encoder.transform([cow_breed])[0]
        encoded_activity = cow_feed_activity_encoder.transform([activity])[0]
        
        # Feed prediction
        feed_input = pd.DataFrame([{
            "Cow Breed": encoded_breed,
            "Cow Age (months)": cow_age,
            "Cow Weight (kg)": cow_weight,
            "Milk Yield (L/day)": milk_yield,
            "Activity Level": encoded_activity
        }])
        
        daily_feed = float(cow_feed_model.predict(feed_input)[0])
        
        return jsonify({
            "mode": "manual",
            "cow_weight_kg": round(cow_weight, 2),
            "daily_feed_kg": round(daily_feed, 2)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ==================== Egg Hatch Prediction ====================
@app.route("/egg-hatch/predict", methods=["POST"])
def predict_egg_hatch():
    if egg_hatch_nn_model is None:
        return jsonify({"error": "Egg hatch model not loaded"}), 503
    
    try:
        data = request.get_json()
        
        df = pd.DataFrame([{
            "Temperature": data["Temperature"],
            "Humidity": data["Humidity"],
            "Egg_Weight": data["Egg_Weight"],
            "Egg_Turning_Frequency": data["Egg_Turning_Frequency"],
            "Incubation_Duration": data["Incubation_Duration"]
        }])
        
        scaled = egg_hatch_scaler.transform(df)
        prob = float(egg_hatch_nn_model.predict(scaled)[0][0])
        pred = 1 if prob >= 0.5 else 0
        
        return jsonify({
            "hatch_probability": prob,
            "predicted_class": pred
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# ==================== Milk Market Prediction ====================
@app.route("/milk-market/predict-income", methods=["POST"])
def predict_milk_market():
    if milk_market_model is None:
        return jsonify({"error": "Milk market model not loaded"}), 503
    
    try:
        data = request.get_json()
        
        input_df = pd.DataFrame([{
            'Local_Milk_Price_LKR_per_Litre': data['current_price'],
            'Monthly_Milk_Litres': data['monthly_milk_litres'],
            'Fat_Percentage': data['fat_percentage'],
            'SNF_Percentage': data['snf_percentage'],
            'Disease_Stage': data['disease_stage'],
            'Feed_Quality_Encoded': data['feed_quality'],
            'Lactation_Month': data['lactation_month'],
            'Month': data['month']
        }])
        
        price_change = milk_market_model.predict(input_df)[0]
        next_price = data['current_price'] + price_change
        next_income = next_price * data['monthly_milk_litres']
        
        return jsonify({
            "predicted_price_change_lkr_per_litre": round(price_change, 2),
            "predicted_next_month_price_lkr_per_litre": round(next_price, 2),
            "predicted_next_month_income_lkr": round(next_income, 2)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# ==================== Nutrition Recommendation ====================
@app.route("/nutrition/predict", methods=["POST"])
def predict_nutrition():
    if nutrition_model is None:
        return jsonify({"error": "Nutrition model not loaded"}), 503
    
    try:
        data = request.get_json()
        
        input_df = pd.DataFrame([{
            "Age_Months": data["Age_Months"],
            "Weight_kg": data["Weight_kg"],
            "Breed": data["Breed"],
            "Milk_Yield_L_per_day": data["Milk_Yield_L_per_day"],
            "Health_Status": data["Health_Status"],
            "Disease": data["Disease"],
            "Body_Condition_Score": data["Body_Condition_Score"],
            "Location": data["Location"],
            "Energy_MJ_per_day": data["Energy_MJ_per_day"],
            "Crude_Protein_g_per_day": data["Crude_Protein_g_per_day"],
            "Recommended_Feed_Type": data["Recommended_Feed_Type"]
        }])
        
        prediction = nutrition_model.predict(input_df)[0]
        
        result = {
            "Dry_Matter_Intake_kg_per_day": round(float(prediction[0]), 2),
            "Calcium_g_per_day": round(float(prediction[1]), 2),
            "Phosphorus_g_per_day": round(float(prediction[2]), 2)
        }
        
        return jsonify({
            "status": "success",
            "prediction": result
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        })

# ==================== Cattle Disease Detection Endpoints ====================

@app.route('/api/health', methods=['GET'])
def cattle_disease_health():
    """Cattle disease detection health check"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'models_loaded': cattle_densenet_model is not None,
        'version': '1.0'
    })

@app.route('/api/models/status', methods=['GET'])
def cattle_models_status():
    """Check status of cattle disease models"""
    return jsonify({
        'densenet121': cattle_densenet_model is not None,
        'yolo_disease': cattle_yolo_disease_model is not None,
        'yolo_behavior': cattle_yolo_behavior_model is not None,
        'severity_model': cattle_severity_model is not None,
        'treatment_model': cattle_treatment_model is not None,
        'behavior_system': BEHAVIOR_AVAILABLE,
        'ultralytics': True
    })

@app.route('/api/disease/detect', methods=['POST'])
def detect_cattle_disease():
    """Detect disease from uploaded cattle image using DenseNet121"""
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400
        
        file = request.files['image']
        use_yolo = request.form.get('use_yolo', 'false').lower() == 'true'
        
        filepath = save_uploaded_file(file)
        if not filepath:
            return jsonify({'error': 'Invalid file format'}), 400
        
        result = {}
        
        # YOLO Detection (fast)
        if use_yolo and cattle_yolo_disease_model:
            yolo_results = cattle_yolo_disease_model(filepath, verbose=False)[0]
            
            if hasattr(yolo_results, 'probs') and yolo_results.probs is not None:
                top_class_id = int(yolo_results.probs.top1)
                top_confidence = float(yolo_results.probs.top1conf)
                predicted_class = cattle_yolo_disease_model.names[top_class_id]
                
                result['yolo'] = {
                    'disease': predicted_class,
                    'confidence': round(top_confidence, 4)
                }
        
        # DenseNet121 Detection (accurate)
        if cattle_densenet_model:
            img_array = process_image_for_cattle_densenet(filepath)
            predictions = cattle_densenet_model.predict(img_array, verbose=0)[0]
            
            top_class_id = int(np.argmax(predictions))
            top_confidence = float(predictions[top_class_id])
            predicted_disease = CattleDiseaseConfig.DISEASE_CLASSES[top_class_id]
            
            all_predictions = {
                CattleDiseaseConfig.DISEASE_CLASSES[i]: round(float(predictions[i]), 4)
                for i in range(len(predictions))
            }
            
            result['densenet'] = {
                'disease': predicted_disease,
                'confidence': round(top_confidence, 4),
                'all_predictions': all_predictions
            }
        
        os.remove(filepath)
        
        # Determine final result
        if 'densenet' in result:
            result['recommended'] = 'densenet'
            result['disease'] = result['densenet']['disease']
            result['confidence'] = result['densenet']['confidence']
        elif 'yolo' in result:
            result['recommended'] = 'yolo'
            result['disease'] = result['yolo']['disease']
            result['confidence'] = result['yolo']['confidence']
        else:
            return jsonify({'error': 'No models available'}), 500
        
        result['timestamp'] = datetime.now().isoformat()
        return jsonify(result)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/disease/analyze', methods=['POST'])
def analyze_cattle_complete():
    """Complete disease analysis: Detection + Severity + Treatment"""
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400
        
        file = request.files['image']
        weight = float(request.form.get('weight', 450))
        age = float(request.form.get('age', 40))
        temperature = float(request.form.get('temperature', 38.5))
        previous_disease = request.form.get('previous_disease', None)
        
        filepath = save_uploaded_file(file)
        if not filepath:
            return jsonify({'error': 'Invalid file format'}), 400
        
        result = {}
        
        # Step 1: Disease Detection
        img_array = process_image_for_cattle_densenet(filepath)
        predictions = cattle_densenet_model.predict(img_array, verbose=0)[0]
        
        top_class_id = int(np.argmax(predictions))
        disease_confidence = float(predictions[top_class_id])
        detected_disease = CattleDiseaseConfig.DISEASE_CLASSES[top_class_id]
        
        result['disease'] = {
            'name': detected_disease,
            'confidence': round(disease_confidence, 4)
        }
        
        # If healthy, no need for severity/treatment
        if detected_disease.lower() == 'healthy':
            result['severity'] = {'level': 'None', 'confidence': 1.0}
            result['treatment'] = {'recommendation': 'No treatment needed', 'confidence': 1.0}
            result['message'] = 'Cow is healthy!'
            os.remove(filepath)
            return jsonify(result)
        
        # Step 2: Severity Assessment
        if cattle_severity_model:
            disease_encoded = cattle_severity_encoders['Disease'].transform([detected_disease])[0]
            
            if previous_disease and previous_disease != 'None':
                try:
                    prev_disease_encoded = cattle_severity_encoders['Previous_Disease'].transform([previous_disease])[0]
                except:
                    prev_disease_encoded = 0
            else:
                prev_disease_encoded = 0
            
            temp_deviation = temperature - 38.5
            weight_age_ratio = weight / (age + 1)
            has_history = 1 if prev_disease_encoded > 0 else 0
            
            severity_features = np.array([[
                disease_encoded, weight, age, temperature, prev_disease_encoded,
                temp_deviation, weight_age_ratio, has_history
            ]])
            
            severity_features_scaled = cattle_severity_scaler.transform(severity_features)
            severity_level = cattle_severity_model.predict(severity_features_scaled)[0]
            severity_proba = cattle_severity_model.predict_proba(severity_features_scaled)[0]
            severity_confidence = severity_proba[severity_level]
            severity_name = CattleDiseaseConfig.SEVERITY_CLASSES[severity_level]
            
            result['severity'] = {
                'level': severity_name,
                'confidence': round(float(severity_confidence), 4),
                'probabilities': {
                    'Mild': round(float(severity_proba[0]), 4),
                    'Moderate': round(float(severity_proba[1]), 4),
                    'Severe': round(float(severity_proba[2]), 4)
                }
            }
            
            # Step 3: Treatment Recommendation
            if cattle_treatment_model:
                disease_encoded_treat = cattle_treatment_encoders['Disease'].transform([detected_disease])[0]
                
                if previous_disease and previous_disease != 'None':
                    try:
                        prev_disease_encoded_treat = cattle_treatment_encoders['Previous_Disease'].transform([previous_disease])[0]
                    except:
                        prev_disease_encoded_treat = 0
                else:
                    prev_disease_encoded_treat = 0
                
                severity_temp_interaction = severity_level * temp_deviation
                
                treatment_features = np.array([[
                    disease_encoded_treat, severity_level, weight, age, temperature,
                    prev_disease_encoded_treat, temp_deviation, weight_age_ratio,
                    has_history, severity_temp_interaction
                ]])
                
                treatment_features_scaled = cattle_treatment_scaler.transform(treatment_features)
                treatment_idx = cattle_treatment_model.predict(treatment_features_scaled)[0]
                treatment_proba = cattle_treatment_model.predict_proba(treatment_features_scaled)[0]
                
                treatment_name = cattle_treatment_encoders['Treatment'].classes_[treatment_idx]
                treatment_confidence = treatment_proba[treatment_idx]
                
                top3_indices = np.argsort(treatment_proba)[-3:][::-1]
                top3_treatments = [
                    {
                        'treatment': cattle_treatment_encoders['Treatment'].classes_[idx],
                        'probability': round(float(treatment_proba[idx]), 4)
                    }
                    for idx in top3_indices
                ]
                
                result['treatment'] = {
                    'primary': treatment_name,
                    'confidence': round(float(treatment_confidence), 4),
                    'alternatives': top3_treatments
                }
        
        os.remove(filepath)
        
        result['timestamp'] = datetime.now().isoformat()
        result['clinical_data'] = {
            'weight': weight,
            'age': age,
            'temperature': temperature,
            'previous_disease': previous_disease
        }
        
        return jsonify(result)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/quick-diagnosis', methods=['POST'])
def quick_cattle_diagnosis():
    """Fast diagnosis using YOLO only"""
    try:
        if not cattle_yolo_disease_model:
            return jsonify({'error': 'YOLO model not available'}), 500
        
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400
        
        file = request.files['image']
        filepath = save_uploaded_file(file)
        if not filepath:
            return jsonify({'error': 'Invalid file format'}), 400
        
        results = cattle_yolo_disease_model(filepath, verbose=False)[0]
        
        if hasattr(results, 'probs') and results.probs is not None:
            top_class_id = int(results.probs.top1)
            top_confidence = float(results.probs.top1conf)
            predicted_class = cattle_yolo_disease_model.names[top_class_id]
            
            top5_indices = results.probs.top5
            top5_conf = results.probs.top5conf
            
            top3 = []
            for i in range(min(3, len(top5_indices))):
                cls_name = cattle_yolo_disease_model.names[top5_indices[i]]
                conf = float(top5_conf[i])
                top3.append({'disease': cls_name, 'confidence': round(conf, 4)})
            
            result = {
                'disease': predicted_class,
                'confidence': round(top_confidence, 4),
                'top3': top3,
                'model': 'YOLOv8x-Classifier',
                'timestamp': datetime.now().isoformat()
            }
            
            os.remove(filepath)
            return jsonify(result)
        else:
            os.remove(filepath)
            return jsonify({'error': 'No predictions from YOLO'}), 500
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/behavior/snapshot', methods=['POST'])
def save_cattle_behavior_snapshot():
    """Save behavior snapshot for a cow"""
    try:
        if not BEHAVIOR_AVAILABLE or not cattle_behavior_collector:
            return jsonify({'error': 'Behavior system not available'}), 500
        
        data = request.get_json()
        
        cow_id = data.get('cow_id')
        eating_time = float(data.get('eating_time', 0))
        lying_time = float(data.get('lying_time', 0))
        steps = int(data.get('steps', 0))
        rumination_time = float(data.get('rumination_time', 0))
        temperature = float(data.get('temperature', 38.5))
        
        snapshot_id = cattle_behavior_collector.save_snapshot(
            cow_id=cow_id,
            eating_time_per_hour=eating_time,
            lying_time_per_hour=lying_time,
            steps_per_hour=steps,
            rumination_time_per_hour=rumination_time,
            temperature=temperature
        )
        
        hours = cattle_behavior_collector.get_hours_of_data(cow_id)
        
        return jsonify({
            'snapshot_id': snapshot_id,
            'cow_id': cow_id,
            'hours_of_data': round(hours, 2),
            'message': 'Snapshot saved successfully',
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/behavior/analyze/<cow_id>', methods=['GET'])
def analyze_cattle_behavior(cow_id):
    """Analyze behavior patterns for a specific cow"""
    try:
        if not BEHAVIOR_AVAILABLE or not cattle_behavior_analyzer:
            return jsonify({'error': 'Behavior system not available'}), 500
        
        hours = int(request.args.get('hours', 24))
        
        result = cattle_behavior_analyzer.analyze_cow(cow_id, hours=hours)
        result['timestamp'] = datetime.now().isoformat()
        
        return jsonify(result)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/behavior/detect-from-video', methods=['POST'])
def detect_cattle_behavior_from_video():
    """Detect behavior from uploaded video frame using YOLOv8s"""
    try:
        if not cattle_yolo_behavior_model:
            return jsonify({'error': 'YOLO behavior model not available'}), 500
        
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400
        
        file = request.files['image']
        filepath = save_uploaded_file(file)
        if not filepath:
            return jsonify({'error': 'Invalid file format'}), 400
        
        results = cattle_yolo_behavior_model(filepath, verbose=False)[0]
        
        behaviors = []
        if hasattr(results, 'boxes') and results.boxes is not None:
            for box in results.boxes:
                cls_id = int(box.cls[0])
                confidence = float(box.conf[0])
                class_name = cattle_yolo_behavior_model.names[cls_id]
                
                behaviors.append({
                    'behavior': class_name,
                    'confidence': round(confidence, 4)
                })
        
        os.remove(filepath)
        
        return jsonify({
            'behaviors': behaviors,
            'count': len(behaviors),
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/video/analyze', methods=['POST'])
def analyze_cattle_video():
    """Analyze video file for both behavior and disease detection"""
    try:
        if 'video' not in request.files:
            return jsonify({'error': 'No video file uploaded'}), 400
        
        file = request.files['video']
        frame_interval = int(request.form.get('frame_interval', 30))
        detect_disease_flag = request.form.get('detect_disease', 'true').lower() == 'true'
        detect_behavior_flag = request.form.get('detect_behavior', 'true').lower() == 'true'
        
        video_path = save_uploaded_video(file)
        if not video_path:
            return jsonify({'error': 'Invalid video file format'}), 400
        
        video_data = process_video_frames(video_path, frame_interval)
        if video_data is None:
            os.remove(video_path)
            return jsonify({'error': 'Failed to process video file'}), 400
        
        frames = video_data['frames']
        fps = video_data['fps']
        
        behavior_timeline = []
        disease_detections = []
        
        for idx, frame in enumerate(frames):
            timestamp = (idx * frame_interval) / fps if fps > 0 else idx
            
            # Detect behavior
            if detect_behavior_flag and cattle_yolo_behavior_model:
                try:
                    frame_bgr = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
                    results = cattle_yolo_behavior_model(frame_bgr, verbose=False)
                    
                    behaviors = []
                    for result in results:
                        if hasattr(result, 'probs') and result.probs is not None:
                            top5_indices = result.probs.top5
                            top5_conf = result.probs.top5conf.cpu().numpy()
                            
                            for i, conf in zip(top5_indices, top5_conf):
                                if conf > 0.3:
                                    behavior_name = result.names[int(i)]
                                    behaviors.append({
                                        'behavior': behavior_name,
                                        'confidence': float(conf)
                                    })
                        
                        elif hasattr(result, 'boxes') and result.boxes is not None and len(result.boxes) > 0:
                            for box in result.boxes:
                                conf = float(box.conf.cpu().numpy()[0])
                                if conf > 0.3:
                                    cls_id = int(box.cls.cpu().numpy()[0])
                                    behavior_name = result.names[cls_id]
                                    behaviors.append({
                                        'behavior': behavior_name,
                                        'confidence': conf
                                    })
                    
                    if behaviors:
                        behavior_timeline.append({
                            'timestamp': round(timestamp, 2),
                            'frame': idx,
                            'behaviors': behaviors
                        })
                except:
                    pass
            
            # Detect disease
            if detect_disease_flag and cattle_yolo_disease_model:
                try:
                    frame_bgr = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
                    results = cattle_yolo_disease_model(frame_bgr, verbose=False)
                    
                    for result in results:
                        if hasattr(result, 'probs') and result.probs is not None:
                            top1_idx = result.probs.top1
                            top1_conf = result.probs.top1conf.cpu().numpy()
                            
                            if top1_conf > 0.5:
                                disease_name = result.names[int(top1_idx)]
                                disease_detections.append({
                                    'timestamp': round(timestamp, 2),
                                    'frame': idx,
                                    'disease': disease_name,
                                    'confidence': float(top1_conf)
                                })
                except:
                    pass
        
        # Aggregate results
        behavior_summary = {}
        for entry in behavior_timeline:
            for behavior in entry['behaviors']:
                behavior_name = behavior['behavior']
                if behavior_name not in behavior_summary:
                    behavior_summary[behavior_name] = {'count': 0, 'total_confidence': 0}
                behavior_summary[behavior_name]['count'] += 1
                behavior_summary[behavior_name]['total_confidence'] += behavior['confidence']
        
        for behavior_name in behavior_summary:
            count = behavior_summary[behavior_name]['count']
            behavior_summary[behavior_name]['avg_confidence'] = round(
                behavior_summary[behavior_name]['total_confidence'] / count, 4
            )
            del behavior_summary[behavior_name]['total_confidence']
        
        disease_summary = {}
        for detection in disease_detections:
            disease_name = detection['disease']
            if disease_name not in disease_summary:
                disease_summary[disease_name] = {
                    'count': 0, 'total_confidence': 0,
                    'first_seen': detection['timestamp'],
                    'last_seen': detection['timestamp']
                }
            disease_summary[disease_name]['count'] += 1
            disease_summary[disease_name]['total_confidence'] += detection['confidence']
            disease_summary[disease_name]['last_seen'] = detection['timestamp']
        
        for disease_name in disease_summary:
            count = disease_summary[disease_name]['count']
            disease_summary[disease_name]['avg_confidence'] = round(
                disease_summary[disease_name]['total_confidence'] / count, 4
            )
            del disease_summary[disease_name]['total_confidence']
        
        os.remove(video_path)
        
        result = {
            'video_info': {
                'duration': round(video_data['duration'], 2),
                'fps': round(fps, 2),
                'total_frames': video_data['total_frames'],
                'analyzed_frames': video_data['extracted_frames'],
                'frame_interval': frame_interval
            },
            'behavior_timeline': behavior_timeline if detect_behavior_flag else None,
            'disease_detections': disease_detections if detect_disease_flag else None,
            'summary': {
                'behaviors': behavior_summary if detect_behavior_flag else None,
                'diseases': disease_summary if detect_disease_flag else None
            },
            'timestamp': datetime.now().isoformat()
        }
        
        return jsonify(result)
    
    except Exception as e:
        if 'video_path' in locals() and os.path.exists(video_path):
            os.remove(video_path)
        return jsonify({'error': str(e)}), 500

# ==================== Run Application ====================
if __name__ == "__main__":
    print("\n" + "="*60)
    print("🚀 Smart Farm AI Backend - Starting...")
    print("="*60 + "\n")
    app.run(host="0.0.0.0", port=5000, debug=True)
