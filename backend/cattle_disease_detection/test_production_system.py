"""
🧪 PRODUCTION SYSTEM TESTING SUITE
===================================
Comprehensive tests for all models and workflows using real images/videos

Tests:
1. Disease Detection Models (DenseNet121/YOLOv8x)
2. Severity Prediction Model
3. Treatment Recommendation Model  
4. Behavior Analysis System
5. Complete Integrated Workflow

Author: Automated Testing System
Date: January 1, 2026
"""

import os
import sys
import glob
import json
import numpy as np
import pandas as pd
from pathlib import Path
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# ============================================================================
# CONFIGURATION
# ============================================================================

class TestConfig:
    """Test configuration and paths"""
    
    # Image paths
    DISEASE_TEST_IMAGES = "cattels_images_videos/images/Disease_test_photo"
    BEHAVIOR_TEST_IMAGES = "cattels_images_videos/images/Behavior_test_photos"
    TEST_VIDEOS = "cattels_images_videos/videos"
    
    # Model paths
    DENSENET121_MODEL = "models/DenseNet121_Disease/best_model.h5"
    SEVERITY_MODEL = "models/Treatment_Severity/best_model_gradient_boosting.pkl"
    TREATMENT_MODEL = "models/Treatment_Recommendation/best_model_gradient_boosting.pkl"
    
    # Expected disease categories
    DISEASE_CATEGORIES = [
        'Contagious', 'Dermatophilosis', 'FMD', 'Healthy',
        'Lumpy Skin', 'Mastitis', 'Pediculosis', 'Ringworm'
    ]
    
    # Test results directory
    RESULTS_DIR = "test_results"

# ============================================================================
# TEST UTILITIES
# ============================================================================

class TestLogger:
    """Log test results"""
    
    def __init__(self):
        self.results = []
        self.passed = 0
        self.failed = 0
        os.makedirs(TestConfig.RESULTS_DIR, exist_ok=True)
        
    def log_test(self, test_name, passed, details=""):
        result = {
            'test_name': test_name,
            'passed': bool(passed),  # Convert to native Python bool
            'details': str(details),
            'timestamp': datetime.now().isoformat()
        }
        self.results.append(result)
        
        if passed:
            self.passed += 1
            print(f"✅ PASS: {test_name}")
        else:
            self.failed += 1
            print(f"❌ FAIL: {test_name}")
        
        if details:
            print(f"   {details}")
    
    def save_results(self):
        """Save test results to JSON"""
        results_file = os.path.join(TestConfig.RESULTS_DIR, 'test_results.json')
        with open(results_file, 'w') as f:
            json.dump({
                'summary': {
                    'total': len(self.results),
                    'passed': self.passed,
                    'failed': self.failed,
                    'pass_rate': f"{(self.passed/len(self.results)*100):.1f}%" if self.results else "0%"
                },
                'tests': self.results
            }, f, indent=2)
        print(f"\n📁 Results saved to: {results_file}")

# ============================================================================
# TEST 1: CHECK FILE STRUCTURE
# ============================================================================

def test_file_structure(logger):
    """Test if all required files and folders exist"""
    
    print("\n" + "="*70)
    print("TEST 1: FILE STRUCTURE VALIDATION")
    print("="*70)
    
    # Check disease images
    disease_path = TestConfig.DISEASE_TEST_IMAGES
    if os.path.exists(disease_path):
        categories = [d for d in os.listdir(disease_path) if os.path.isdir(os.path.join(disease_path, d))]
        logger.log_test(
            "Disease test images folder exists",
            True,
            f"Found {len(categories)} disease categories: {', '.join(categories)}"
        )
        
        # Count images per category
        for category in categories:
            cat_path = os.path.join(disease_path, category)
            images = glob.glob(os.path.join(cat_path, "*.[jJ][pP][gG]")) + \
                    glob.glob(os.path.join(cat_path, "*.[pP][nN][gG]"))
            logger.log_test(
                f"  Category '{category}' has images",
                len(images) > 0,
                f"{len(images)} images found"
            )
    else:
        logger.log_test("Disease test images folder exists", False, f"Path not found: {disease_path}")
    
    # Check behavior images
    behavior_path = TestConfig.BEHAVIOR_TEST_IMAGES
    if os.path.exists(behavior_path):
        images = glob.glob(os.path.join(behavior_path, "*.[jJ][pP][gG]")) + \
                glob.glob(os.path.join(behavior_path, "*.[pP][nN][gG]"))
        logger.log_test(
            "Behavior test images folder exists",
            True,
            f"Found {len(images)} behavior images"
        )
    else:
        logger.log_test("Behavior test images folder exists", False, f"Path not found: {behavior_path}")
    
    # Check videos
    videos_path = TestConfig.TEST_VIDEOS
    if os.path.exists(videos_path):
        videos = glob.glob(os.path.join(videos_path, "*.[mM][pP]4")) + \
                glob.glob(os.path.join(videos_path, "*.[aA][vV][iI]"))
        logger.log_test(
            "Videos folder exists",
            True,
            f"Found {len(videos)} video files"
        )
    else:
        logger.log_test("Videos folder exists", False, f"Path not found: {videos_path}")

# ============================================================================
# TEST 2: MODEL FILE VALIDATION
# ============================================================================

def test_model_files(logger):
    """Test if all model files exist and are loadable"""
    
    print("\n" + "="*70)
    print("TEST 2: MODEL FILES VALIDATION")
    print("="*70)
    
    # Test DenseNet121 model
    densenet_path = TestConfig.DENSENET121_MODEL
    if os.path.exists(densenet_path):
        try:
            from tensorflow import keras
            model = keras.models.load_model(densenet_path)
            logger.log_test(
                "DenseNet121 model loads successfully",
                True,
                f"Model shape: {model.input_shape} → {model.output_shape}"
            )
        except Exception as e:
            logger.log_test(
                "DenseNet121 model loads successfully",
                False,
                f"Error: {str(e)}"
            )
    else:
        logger.log_test("DenseNet121 model file exists", False, f"Path not found: {densenet_path}")
    
    # Test Severity model
    severity_path = TestConfig.SEVERITY_MODEL
    if os.path.exists(severity_path):
        try:
            import joblib
            model = joblib.load(severity_path)
            logger.log_test(
                "Severity model loads successfully",
                True,
                f"Model type: {type(model).__name__}"
            )
        except Exception as e:
            logger.log_test(
                "Severity model loads successfully",
                False,
                f"Error: {str(e)}"
            )
    else:
        logger.log_test("Severity model file exists", False, f"Path not found: {severity_path}")
    
    # Test Treatment model
    treatment_path = TestConfig.TREATMENT_MODEL
    if os.path.exists(treatment_path):
        try:
            import joblib
            model = joblib.load(treatment_path)
            logger.log_test(
                "Treatment model loads successfully",
                True,
                f"Model type: {type(model).__name__}"
            )
        except Exception as e:
            logger.log_test(
                "Treatment model loads successfully",
                False,
                f"Error: {str(e)}"
            )
    else:
        logger.log_test("Treatment model file exists", False, f"Path not found: {treatment_path}")

# ============================================================================
# TEST 3: DISEASE DETECTION WITH REAL IMAGES
# ============================================================================

def test_disease_detection(logger):
    """Test disease detection models with real images"""
    
    print("\n" + "="*70)
    print("TEST 3: DISEASE DETECTION WITH REAL IMAGES")
    print("="*70)
    
    try:
        from tensorflow import keras
        import cv2
        
        # Load DenseNet121 model
        model = keras.models.load_model(TestConfig.DENSENET121_MODEL)
        
        # Test each disease category
        disease_path = TestConfig.DISEASE_TEST_IMAGES
        categories = [d for d in os.listdir(disease_path) if os.path.isdir(os.path.join(disease_path, d))]
        
        for category in categories:
            cat_path = os.path.join(disease_path, category)
            images = glob.glob(os.path.join(cat_path, "*.[jJ][pP][gG]"))[:3]  # Test first 3 images
            
            if not images:
                images = glob.glob(os.path.join(cat_path, "*.[pP][nN][gG]"))[:3]
            
            if images:
                print(f"\n🔍 Testing category: {category}")
                for img_path in images:
                    try:
                        # Load and preprocess image
                        img = cv2.imread(img_path)
                        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
                        img = cv2.resize(img, (224, 224))
                        img_array = np.expand_dims(img, axis=0)
                        img_array = img_array / 255.0
                        
                        # Predict
                        predictions = model.predict(img_array, verbose=0)
                        confidence = float(np.max(predictions))
                        
                        logger.log_test(
                            f"  Image: {os.path.basename(img_path)}",
                            confidence > 0.3,  # At least 30% confidence
                            f"Confidence: {confidence:.2%}"
                        )
                    except Exception as e:
                        logger.log_test(
                            f"  Image: {os.path.basename(img_path)}",
                            False,
                            f"Error: {str(e)}"
                        )
    
    except ImportError:
        logger.log_test(
            "Disease detection test",
            False,
            "Required libraries (tensorflow, cv2) not installed"
        )
    except Exception as e:
        logger.log_test(
            "Disease detection test",
            False,
            f"Error: {str(e)}"
        )

# ============================================================================
# TEST 4: SEVERITY & TREATMENT MODELS
# ============================================================================

def test_severity_treatment_models(logger):
    """Test severity and treatment prediction with sample data"""
    
    print("\n" + "="*70)
    print("TEST 4: SEVERITY & TREATMENT PREDICTION")
    print("="*70)
    
    try:
        import joblib
        
        # Load models and encoders
        severity_model = joblib.load(TestConfig.SEVERITY_MODEL)
        severity_scaler = joblib.load("models/Treatment_Severity/scaler.pkl")
        severity_encoders = joblib.load("models/Treatment_Severity/label_encoders.pkl")
        
        treatment_model = joblib.load(TestConfig.TREATMENT_MODEL)
        treatment_scaler = joblib.load("models/Treatment_Recommendation/scaler.pkl")
        treatment_encoders = joblib.load("models/Treatment_Recommendation/label_encoders.pkl")
        
        # Test cases
        test_cases = [
            {
                'name': 'Mild Mastitis',
                'disease': 'Mastitis',
                'weight': 450,
                'age': 40,
                'temperature': 38.8,
                'previous_disease': None
            },
            {
                'name': 'Severe FMD',
                'disease': 'FMD',
                'weight': 380,
                'age': 25,
                'temperature': 41.0,
                'previous_disease': 'Mastitis'
            },
            {
                'name': 'Moderate Lumpy Skin',
                'disease': 'Lumpy Skin',
                'weight': 420,
                'age': 35,
                'temperature': 39.5,
                'previous_disease': None
            }
        ]
        
        for test_case in test_cases:
            print(f"\n🧪 Testing: {test_case['name']}")
            
            try:
                # Encode disease
                disease_encoded = severity_encoders['Disease'].transform([test_case['disease']])[0]
                
                # Encode previous disease
                if test_case['previous_disease']:
                    prev_disease_encoded = severity_encoders['Previous_Disease'].transform([test_case['previous_disease']])[0]
                else:
                    prev_disease_encoded = 0
                
                # Prepare severity features
                temp_deviation = test_case['temperature'] - 38.5
                weight_age_ratio = test_case['weight'] / (test_case['age'] + 1)
                has_history = 1 if prev_disease_encoded > 0 else 0
                
                severity_features = np.array([[
                    disease_encoded,
                    test_case['weight'],
                    test_case['age'],
                    test_case['temperature'],
                    prev_disease_encoded,
                    temp_deviation,
                    weight_age_ratio,
                    has_history
                ]])
                
                # Predict severity
                severity_features_scaled = severity_scaler.transform(severity_features)
                severity_level = severity_model.predict(severity_features_scaled)[0]
                severity_proba = severity_model.predict_proba(severity_features_scaled)[0]
                severity_confidence = severity_proba[severity_level]
                
                severity_names = {0: 'Mild', 1: 'Moderate', 2: 'Severe'}
                severity_name = severity_names[severity_level]
                
                logger.log_test(
                    f"  Severity prediction for {test_case['name']}",
                    severity_confidence > 0.5,
                    f"Predicted: {severity_name}, Confidence: {severity_confidence:.2%}"
                )
                
                # Prepare treatment features
                disease_encoded_treat = treatment_encoders['Disease'].transform([test_case['disease']])[0]
                
                if test_case['previous_disease']:
                    prev_disease_encoded_treat = treatment_encoders['Previous_Disease'].transform([test_case['previous_disease']])[0]
                else:
                    prev_disease_encoded_treat = 0
                
                severity_temp_interaction = severity_level * temp_deviation
                
                treatment_features = np.array([[
                    disease_encoded_treat,
                    severity_level,
                    test_case['weight'],
                    test_case['age'],
                    test_case['temperature'],
                    prev_disease_encoded_treat,
                    temp_deviation,
                    weight_age_ratio,
                    has_history,
                    severity_temp_interaction
                ]])
                
                # Predict treatment
                treatment_features_scaled = treatment_scaler.transform(treatment_features)
                treatment_idx = treatment_model.predict(treatment_features_scaled)[0]
                treatment_proba = treatment_model.predict_proba(treatment_features_scaled)[0]
                
                treatment = treatment_encoders['Treatment'].classes_[treatment_idx]
                treatment_confidence = treatment_proba[treatment_idx]
                
                logger.log_test(
                    f"  Treatment prediction for {test_case['name']}",
                    treatment_confidence > 0.5,
                    f"Predicted: {treatment}, Confidence: {treatment_confidence:.2%}"
                )
                
            except Exception as e:
                logger.log_test(
                    f"  Prediction for {test_case['name']}",
                    False,
                    f"Error: {str(e)}"
                )
    
    except Exception as e:
        logger.log_test(
            "Severity & Treatment models test",
            False,
            f"Error: {str(e)}"
        )

# ============================================================================
# TEST 5: BEHAVIOR DATA COLLECTION
# ============================================================================

def test_behavior_system(logger):
    """Test behavior data collection and analysis"""
    
    print("\n" + "="*70)
    print("TEST 5: BEHAVIOR DATA COLLECTION & ANALYSIS")
    print("="*70)
    
    try:
        from behavior_data_manager import BehaviorDataCollector, BehaviorAnalyzer
        
        # Initialize
        collector = BehaviorDataCollector()
        analyzer = BehaviorAnalyzer(collector)
        
        # Test data collection
        test_cow_id = "TEST-001"
        
        snapshot_id = collector.save_snapshot(
            cow_id=test_cow_id,
            eating_time_per_hour=10.5,
            lying_time_per_hour=0.5,
            steps_per_hour=180,
            rumination_time_per_hour=20,
            temperature=38.6
        )
        
        logger.log_test(
            "Behavior snapshot collection",
            snapshot_id is not None,
            f"Snapshot saved with ID: {snapshot_id}"
        )
        
        # Test data retrieval
        cow_data = collector.get_cow_data(test_cow_id, hours=24)
        
        logger.log_test(
            "Behavior data retrieval",
            len(cow_data) > 0,
            f"Retrieved {len(cow_data)} data points"
        )
        
        # Test if CSV file was created
        history_file = "behavior_data/behavior_history.csv"
        
        logger.log_test(
            "Behavior history CSV created",
            os.path.exists(history_file),
            f"File: {history_file}"
        )
        
    except ImportError:
        logger.log_test(
            "Behavior system test",
            False,
            "behavior_data_manager.py not found or has errors"
        )
    except Exception as e:
        logger.log_test(
            "Behavior system test",
            False,
            f"Error: {str(e)}"
        )

# ============================================================================
# TEST 6: INTEGRATION TEST
# ============================================================================

def test_integration(logger):
    """Test complete integrated workflow"""
    
    print("\n" + "="*70)
    print("TEST 6: COMPLETE INTEGRATION TEST")
    print("="*70)
    
    try:
        # Try to import integrated system
        from integrated_cattle_diagnosis_system import MODEL_LOADER, assess_severity, recommend_treatment
        
        # Load models
        MODEL_LOADER.load_all_models()
        
        logger.log_test(
            "Integrated system imports successfully",
            True,
            "All modules loaded"
        )
        
        # Test integrated workflow
        disease = "Mastitis"
        weight = 450
        age = 40
        temperature = 39.5
        
        print(f"\n🔄 Testing integrated workflow for {disease}...")
        
        # Test severity assessment
        severity_level, severity_name, severity_confidence = assess_severity(
            disease, weight, age, temperature, None
        )
        
        logger.log_test(
            "Integrated severity assessment",
            severity_confidence > 0.5,
            f"Severity: {severity_name}, Confidence: {severity_confidence:.2%}"
        )
        
        # Test treatment recommendation
        treatment, treatment_confidence, top_3 = recommend_treatment(
            disease, severity_level, weight, age, temperature, None
        )
        
        logger.log_test(
            "Integrated treatment recommendation",
            treatment_confidence > 0.5,
            f"Treatment: {treatment}, Confidence: {treatment_confidence:.2%}"
        )
        
    except ImportError as e:
        logger.log_test(
            "Integration test",
            False,
            f"Import error: {str(e)}"
        )
    except Exception as e:
        logger.log_test(
            "Integration test",
            False,
            f"Error: {str(e)}"
        )

# ============================================================================
# MAIN TEST RUNNER
# ============================================================================

def run_all_tests():
    """Run complete test suite"""
    
    print("\n" + "="*70)
    print("🧪 CATTLE DISEASE DETECTION SYSTEM - PRODUCTION TESTING")
    print("="*70)
    print(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Working Directory: {os.getcwd()}")
    print("="*70)
    
    logger = TestLogger()
    
    # Run all tests
    test_file_structure(logger)
    test_model_files(logger)
    test_disease_detection(logger)
    test_severity_treatment_models(logger)
    test_behavior_system(logger)
    test_integration(logger)
    
    # Print summary
    print("\n" + "="*70)
    print("📊 TEST SUMMARY")
    print("="*70)
    print(f"Total Tests: {logger.passed + logger.failed}")
    print(f"✅ Passed: {logger.passed}")
    print(f"❌ Failed: {logger.failed}")
    if logger.passed + logger.failed > 0:
        pass_rate = logger.passed / (logger.passed + logger.failed) * 100
        print(f"📈 Pass Rate: {pass_rate:.1f}%")
        
        if pass_rate == 100:
            print("\n🎉 ALL TESTS PASSED! System is production-ready!")
        elif pass_rate >= 80:
            print("\n✅ Most tests passed. System is mostly functional.")
        elif pass_rate >= 50:
            print("\n⚠️ Some tests failed. Review failed tests.")
        else:
            print("\n❌ Many tests failed. System needs fixes.")
    
    print("="*70)
    
    # Save results
    logger.save_results()
    
    return logger

if __name__ == "__main__":
    logger = run_all_tests()
    
    print("\n💡 RECOMMENDATIONS:")
    print("-" * 70)
    print("1. Review test_results/test_results.json for detailed results")
    print("2. If disease detection failed, check if images are in correct format")
    print("3. If model loading failed, ensure all model files are present")
    print("4. Run 'pip install -r requirements.txt' if import errors occur")
    print("5. For detailed testing, check individual test functions")
    print("-" * 70)
