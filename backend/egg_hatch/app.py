from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import pandas as pd
import tensorflow as tf

app = Flask(__name__)
CORS(app)

# Load model & scaler ONCE
SCALER_PATH = "egg_hatch_scaler.joblib"
NN_MODEL_PATH = "egg_hatch_nn.h5"

scaler = joblib.load(SCALER_PATH)
nn_model = tf.keras.models.load_model(NN_MODEL_PATH)

@app.route("/")
def home():
    return "Egg Hatch Prediction API is running"

@app.route("/egg-hatch/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()

        # Convert input to DataFrame
        df = pd.DataFrame([{
            "Temperature": data["Temperature"],
            "Humidity": data["Humidity"],
            "Egg_Weight": data["Egg_Weight"],
            "Egg_Turning_Frequency": data["Egg_Turning_Frequency"],
            "Incubation_Duration": data["Incubation_Duration"]
        }])

        # Scale input
        scaled = scaler.transform(df)

        # Predict
        prob = float(nn_model.predict(scaled)[0][0])
        pred = 1 if prob >= 0.5 else 0

        return jsonify({
            "hatch_probability": prob,
            "predicted_class": pred
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 400


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
