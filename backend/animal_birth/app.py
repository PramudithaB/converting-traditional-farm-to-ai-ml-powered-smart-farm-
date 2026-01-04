from flask import Flask, request, jsonify
import joblib
import numpy as np

app = Flask(__name__)

# Load model
MODEL_PATH = "clf.pkl"
model = joblib.load(MODEL_PATH)

@app.route("/")
def home():
    return "Animal Birth Prediction API is running 🚀"

@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()

        # Example input: features array
        features = np.array(data["features"]).reshape(1, -1)

        # Predict days to birth
        predicted_days = float(model.predict(features)[0])

        # Business logic
        will_birth_2_days = "Yes" if predicted_days <= 2 else "No"

        return jsonify({
            "Will Birth in Next 2 Days": will_birth_2_days,
            "Estimated Days to Birth": round(predicted_days, 1)
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(debug=True)
