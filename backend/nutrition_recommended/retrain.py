import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestRegressor

df = pd.read_csv("nutrition_dataset.csv")

target_cols = [
    "Dry_Matter_Intake_kg_per_day",
    "Calcium_g_per_day",
    "Phosphorus_g_per_day"
]

y = df[target_cols]
X = df.drop(columns=target_cols)

categorical_cols = [
    "Breed",
    "Health_Status",
    "Disease",
    "Location",
    "Recommended_Feed_Type"
]
numeric_cols = [c for c in X.columns if c not in categorical_cols]

preprocessor = ColumnTransformer([
    ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_cols),
    ("num", "passthrough", numeric_cols)
])

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

model = Pipeline([
    ("preprocess", preprocessor),
    ("model", RandomForestRegressor(n_estimators=200, random_state=42, n_jobs=-1))
])

model.fit(X_train, y_train)
joblib.dump(model, "multi_output_nutrition_model.pkl")
print("Done! Model saved to multi_output_nutrition_model.pkl")
