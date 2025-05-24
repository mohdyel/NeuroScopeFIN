import os
import base64
import io

import cv2
import numpy as np
import pandas as pd

# use non-interactive backend
import matplotlib
matplotlib.use('Agg')

import matplotlib.pyplot as plt

import keras
import keras_cv
import requests

from flask import Flask, request, jsonify
from flask_cors import CORS, cross_origin

# ------------------------------------------------------------------ config
class CFG:
    image_size   = [400, 300]
    num_classes  = 6
    preset       = "efficientnetv2_b2_imagenet"
    weights_path = "99.keras"
    label2name   = {
        0: "Seizure", 1: "LPD",  2: "GPD",
        3: "LRDA",    4: "GRDA", 5: "Other"
    }

# ------------------------------------------------------------- load model
model = keras_cv.models.ImageClassifier.from_preset(
    CFG.preset, num_classes=CFG.num_classes
)
model.compile(
    optimizer=keras.optimizers.Adam(1e-4),
    loss=keras.losses.KLDivergence()
)
model.load_weights(CFG.weights_path)
print("✔ model loaded")

def run_inference(spec2d: np.ndarray) -> str:
    img = np.stack([spec2d]*3, axis=-1)[None]
    probs = model.predict(img, verbose=0)
    idx = int(np.argmax(probs, -1)[0])
    return CFG.label2name[idx]

# --------------------------------------------------------------- utilities
def convert_parquet_to_spectrogram(source_bytes: bytes,
                                   target_shape=(400,300)) -> np.ndarray:
    df = pd.read_parquet(io.BytesIO(source_bytes))
    spec = df.fillna(0).values[:,1:].T.astype(np.float32)
    h, w = spec.shape
    if h != target_shape[0]:
        spec = cv2.resize(spec, (w, target_shape[0]))
    if w < target_shape[1]:
        spec = np.pad(spec, ((0,0),(0,target_shape[1]-w)))
    else:
        spec = spec[:, :target_shape[1]]
    spec = np.clip(spec, np.exp(-4.0), np.exp(8.0))
    spec = np.log(spec)
    spec = (spec - spec.mean()) / (spec.std() + 1e-6)
    return spec

def make_png_bytes(spec2d: np.ndarray, pred_class: str) -> bytes:
    buf = io.BytesIO()
    plt.figure(figsize=(5,4))
    plt.imshow(spec2d, cmap='viridis', aspect='auto')
    plt.colorbar(label='Intensity')
    plt.title(f"Predicted: {pred_class}")
    plt.tight_layout()
    plt.savefig(buf, format='png', dpi=150)
    plt.close()
    buf.seek(0)
    return buf.read()

# ------------------------------------------------------------------- Flask app
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

@app.route('/predict_bytes', methods=['OPTIONS','POST'])
@cross_origin()
def predict_bytes():
    if request.method == 'OPTIONS':
        return '', 200
    j = request.get_json(force=True)
    b64 = j.get('file_b64')
    name = j.get('file_name', '')
    if not b64:
        return jsonify(error='no file_b64 provided'), 400
    try:
        raw = base64.b64decode(b64)
    except Exception:
        return jsonify(error='invalid base64'), 400

    spec2d = convert_parquet_to_spectrogram(raw, tuple(CFG.image_size))
    cls = run_inference(spec2d)
    png = make_png_bytes(spec2d, cls)
    img_b64 = base64.b64encode(png).decode()

    return jsonify(class_=cls, image_b64=img_b64, file_name=name), 200

@app.route('/upload', methods=['POST'])
@cross_origin()
def upload_image():
    pid  = request.form.get('patientid')
    user = request.form.get('username')
    pred = request.form.get('prediction')
    f    = request.files.get('image')
    if not all([pid, user, pred, f]):
        return jsonify(error='missing fields'), 400
    try:
        resp = requests.post(
            'http://neuroscope.atwebpages.com/php/upload.php',
            data={'patientid': pid, 'username': user, 'prediction': pred},
            files={'image': (f.filename, f.stream, f.mimetype)},
            timeout=15
        )
        resp.raise_for_status()
        return jsonify(resp.json()), resp.status_code
    except requests.RequestException as e:
        return jsonify(error=f"forward failed: {e}"), 502

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    app.run(host='0.0.0.0', port=port, debug=True)
