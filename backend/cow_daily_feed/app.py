from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from tensorflow.keras import backend as K
import numpy as np
import pandas as pd
import joblib
import os

app = Flask(__name__)
CORS(app)


def dice_coef(y_true, y_pred, smooth=1e-6):
    y_true_f = K.flatten(y_true)
    y_pred_f = K.flatten(y_pred)
    intersection = K.sum(y_true_f * y_pred_f)
    return (2. * intersection + smooth) / (
        K.sum(y_true_f) + K.sum(y_pred_f) + smooth
    )


BASE_DIR = "models"

SEG_MODEL_PATH = os.path.join(BASE_DIR, "best_seg_model.h5")
REG_MODEL_PATH = os.path.join(BASE_DIR, "best_reg_model.h5")
FEED_MODEL_PATH = os.path.join(BASE_DIR, "cow_feed_predictor.pkl")

BREED_ENCODER_PATH = os.path.join(BASE_DIR, "breed_encoder.pkl")
ACTIVITY_ENCODER_PATH = os.path.join(BASE_DIR, "activity_encoder.pkl")


seg_model = load_model(
    SEG_MODEL_PATH,
    custom_objects={"dice_coef": dice_coef}
)

reg_model = load_model(REG_MODEL_PATH, compile=False)
feed_model = joblib.load(FEED_MODEL_PATH)

le_breed = joblib.load(BREED_ENCODER_PATH)
le_activity = joblib.load(ACTIVITY_ENCODER_PATH)

IMG_SIZE = (224, 224)

def process_image(img_path):
    img = image.load_img(img_path, target_size=IMG_SIZE)
    img_array = image.img_to_array(img) / 255.0
    return np.expand_dims(img_array, axis=0)


@app.route("/cow-feed/predict-from-image", methods=["POST"])
def predict_from_image():
    try:
        # ---------- Image ----------
        img_file = request.files["image"]
        img_path = "temp.jpg"
        img_file.save(img_path)

        # ---------- Inputs ----------
        cow_breed = request.form.get("breed").strip().title()
        cow_age = float(request.form.get("age"))
        milk_yield = float(request.form.get("milk_yield"))
        activity = request.form.get("activity").strip().title()

        # ---------- Validate ----------
        if cow_breed not in le_breed.classes_:
            return jsonify({
                "error": f"Invalid breed. Allowed: {list(le_breed.classes_)}"
            }), 400

        if activity not in le_activity.classes_:
            return jsonify({
                "error": f"Invalid activity. Allowed: {list(le_activity.classes_)}"
            }), 400

        # ---------- Encode ----------
        encoded_breed = le_breed.transform([cow_breed])[0]
        encoded_activity = le_activity.transform([activity])[0]

        # ---------- Segmentation ----------
        input_image = process_image(img_path)
        predicted_mask = seg_model.predict(input_image)

        # Ensure correct shape for regression
        predicted_mask = predicted_mask[..., :1]

        # ---------- Weight ----------
        predicted_weight = reg_model.predict(predicted_mask)
        cow_weight = float(predicted_weight[0][0])

        # ---------- Feed ----------
        feed_input = pd.DataFrame([{
            "Cow Breed": encoded_breed,
            "Cow Age (months)": cow_age,
            "Cow Weight (kg)": cow_weight,
            "Milk Yield (L/day)": milk_yield,
            "Activity Level": encoded_activity
        }])

        daily_feed = float(feed_model.predict(feed_input)[0])

        os.remove(img_path)

        return jsonify({
            "mode": "image",
            "cow_weight_kg": round(cow_weight, 2),
            "daily_feed_kg": round(daily_feed, 2)
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/cow-feed/predict-manual", methods=["POST"])
def predict_manual():
    try:
        data = request.get_json()

        cow_breed = data["breed"].strip().title()
        cow_age = float(data["age"])
        cow_weight = float(data["weight"])
        milk_yield = float(data["milk_yield"])
        activity = data["activity"].strip().title()

        # ---------- Validate ----------
        if cow_breed not in le_breed.classes_:
            return jsonify({
                "error": f"Invalid breed. Allowed: {list(le_breed.classes_)}"
            }), 400

        if activity not in le_activity.classes_:
            return jsonify({
                "error": f"Invalid activity. Allowed: {list(le_activity.classes_)}"
            }), 400

        # ---------- Encode ----------
        encoded_breed = le_breed.transform([cow_breed])[0]
        encoded_activity = le_activity.transform([activity])[0]

        # ---------- Feed ----------
        feed_input = pd.DataFrame([{
            "Cow Breed": encoded_breed,
            "Cow Age (months)": cow_age,
            "Cow Weight (kg)": cow_weight,
            "Milk Yield (L/day)": milk_yield,
            "Activity Level": encoded_activity
        }])

        daily_feed = float(feed_model.predict(feed_input)[0])

        return jsonify({
            "mode": "manual",
            "cow_weight_kg": round(cow_weight, 2),
            "daily_feed_kg": round(daily_feed, 2)
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
