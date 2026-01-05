from flask import Flask, request, jsonify
from flask_cors import CORS
from ultralytics import YOLO
import cv2
import numpy as np
import os
from PIL import Image

app = Flask(__name__)
CORS(app)

MODEL_PATH = "best.pt"
model = YOLO(MODEL_PATH)

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/cow-identify/detect", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "No image file provided"}), 400

    file = request.files["image"]

    image = Image.open(file).convert("RGB")
    image_np = np.array(image)
    results = model.predict(source=image_np, conf=0.25)

    names = model.names
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


@app.route("/", methods=["GET"])
def home():
    return "Cow Identification YOLO API is running "


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
