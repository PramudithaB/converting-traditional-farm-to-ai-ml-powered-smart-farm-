from flask import Flask, request, jsonify
import pandas as pd
import joblib


MODEL_PATH = "multi_output_nutrition_model.pkl"
model = joblib.load(MODEL_PATH)

app = Flask(__name__)


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "message": "Cow Nutrition Prediction API",
        "outputs": [
            "Dry_Matter_Intake_kg_per_day",
            "Calcium_g_per_day",
            "Phosphorus_g_per_day"
        ]
    })


@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()

        # Convert JSON to DataFrame
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

        # Predict
        prediction = model.predict(input_df)[0]

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


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
