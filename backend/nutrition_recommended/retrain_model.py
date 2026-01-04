"""
Retrain Nutrition Model with Current Sklearn Version
This script retrains the nutrition model to be compatible with your current sklearn version.
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.multioutput import MultiOutputRegressor
from sklearn.ensemble import RandomForestRegressor
import joblib
import os

print("="*60)
print("Retraining Nutrition Model")
print("="*60)

# Load dataset
print("\n1. Loading dataset...")
df = pd.read_csv('nutrition_dataset.csv')
print(f"   Dataset shape: {df.shape}")

# Prepare features and targets
print("\n2. Preparing features and targets...")
feature_columns = [
    'Age_Months', 'Weight_kg', 'Breed', 'Milk_Yield_L_per_day',
    'Health_Status', 'Disease', 'Body_Condition_Score', 'Location',
    'Energy_MJ_per_day', 'Crude_Protein_g_per_day', 'Recommended_Feed_Type'
]

target_columns = [
    'Dry_Matter_Intake_kg_per_day',
    'Calcium_g_per_day',
    'Phosphorus_g_per_day'
]

X = df[feature_columns]
y = df[target_columns]

# Identify categorical columns
categorical_features = ['Breed', 'Health_Status', 'Disease', 'Location', 'Recommended_Feed_Type']
numerical_features = ['Age_Months', 'Weight_kg', 'Milk_Yield_L_per_day', 
                     'Body_Condition_Score', 'Energy_MJ_per_day', 'Crude_Protein_g_per_day']

print(f"   Categorical features: {len(categorical_features)}")
print(f"   Numerical features: {len(numerical_features)}")

# Split data
print("\n3. Splitting data...")
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
print(f"   Training samples: {len(X_train)}")
print(f"   Testing samples: {len(X_test)}")

# Create preprocessor
print("\n4. Creating preprocessor...")
preprocessor = ColumnTransformer(
    transformers=[
        ('num', StandardScaler(), numerical_features),
        ('cat', OneHotEncoder(drop='first', sparse_output=False, handle_unknown='ignore'), categorical_features)
    ])

# Create and train model
print("\n5. Training model...")
model = MultiOutputRegressor(
    RandomForestRegressor(
        n_estimators=100,
        max_depth=20,
        min_samples_split=5,
        min_samples_leaf=2,
        random_state=42,
        n_jobs=-1
    )
)

# Fit preprocessor and transform data
X_train_processed = preprocessor.fit_transform(X_train)
X_test_processed = preprocessor.transform(X_test)

# Train model
model.fit(X_train_processed, y_train)
print("   Model training complete!")

# Evaluate
print("\n6. Evaluating model...")
train_score = model.score(X_train_processed, y_train)
test_score = model.score(X_test_processed, y_test)
print(f"   Training R² score: {train_score:.4f}")
print(f"   Testing R² score: {test_score:.4f}")

# Save complete pipeline
print("\n7. Saving model...")

# Create a wrapper that includes preprocessing
class NutritionPipeline:
    def __init__(self, preprocessor, model):
        self.preprocessor = preprocessor
        self.model = model
    
    def predict(self, X):
        X_processed = self.preprocessor.transform(X)
        return self.model.predict(X_processed)

pipeline = NutritionPipeline(preprocessor, model)

# Save the pipeline
joblib.dump(pipeline, 'multi_output_nutrition_model.pkl')
print("   Model saved as 'multi_output_nutrition_model.pkl'")

# Test the saved model
print("\n8. Testing saved model...")
loaded_model = joblib.load('multi_output_nutrition_model.pkl')
test_input = X_test.iloc[0:1]
prediction = loaded_model.predict(test_input)
print(f"   Test prediction: {prediction}")
print("   ✓ Model loads and predicts successfully!")

print("\n" + "="*60)
print("Model retraining complete!")
print("="*60)
print("\nThe nutrition model is now compatible with your sklearn version.")
print("Restart your backend server to use the new model.\n")
