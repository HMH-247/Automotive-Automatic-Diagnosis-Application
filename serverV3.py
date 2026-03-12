# FastAPI web framework and file upload tools
from fastapi import FastAPI, UploadFile, File, Form, Body
from fastapi.responses import JSONResponse

# TensorFlow Keras tools for loading, preprocessing and training models
from tensorflow import keras, data as tf_data
from tensorflow.keras.models import load_model, Model #type: ignore
from tensorflow.keras.preprocessing import image #type: ignore
from tensorflow.keras.applications.vgg16 import preprocess_input, VGG16 #type: ignore
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D #type: ignore
from tensorflow.keras import layers, utils as keras_utils #type: ignore

# Other Python tools
from scipy.stats import weibull_min  # For fitting distributions in OpenMax
from PIL import Image                # For image loading and processing
import os, io, glob, zipfile         # File I/O and directory operations
from shutil import rmtree            # Remove folders
from datetime import datetime        # Time tracking
import numpy as np                   # Array and math operations
from typing import List              # For type hints

# Initialize FastAPI app
app = FastAPI(title="Radar Classifier with OpenMax Retrainable")

# Choose alpha_rank (how many top logits to consider in OpenMax)
def get_alpha_rank(data_dir: str) -> int:
    # Count how many subfolders (classes) are in the dataset
    num_classes = len([d for d in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, d))])
    
    # Choose alpha_rank based on number of classes
    if num_classes <= 3:
        return 2
    elif 4 <= num_classes <= 10:
        return 4
    else:
        return 6

# Configuration
IMAGE_SIZE = 224
BATCHSIZE = 16
EPOCHS = 10
MODEL_PATH = "VGG16_model_GDI.h5"
DATA_DIR = "GDI"
TAIL_SIZE = 3
ALPHA_RANK = get_alpha_rank(DATA_DIR)

# Global placeholders
base_model = None
feature_model = None
class_names = []
mavs = {}            # Mean Activation Vectors
weibull_models = {}  # Weibull models for each class

# =========================================================================== #
# OpenMax Algorithm
# Convert image to activation vector
def get_activation_vector(img_path):
    # Load image and convert to VGG16 input format
    img = image.load_img(img_path, target_size=(IMAGE_SIZE, IMAGE_SIZE))
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis=0)
    x = preprocess_input(x)

    # Extract feature vector from intermediate layer
    act = feature_model.predict(x)
    return act.flatten()

# Update OpenMax support structures
# This function refreshes or initializes all internal components of the OpenMax algorithm:
# (1)Loads the trained model, (2)Extracts a feature model (used for activation vectors)
# (3)Calculates Mean Activation Vectors (MAVs), (4)Fits Weibull distributions to each class's distance tail
def refresh_openmax_pipeline():
    global base_model, feature_model, class_names, mavs, weibull_models

    # Load the trained model
    base_model = load_model(MODEL_PATH)
    
    # Extract feature model (output from the second-to-last layer)
    feature_layer_name = base_model.layers[-2].name
    feature_model = Model(inputs=base_model.input,
                          outputs=base_model.get_layer(feature_layer_name).output)

    # Get class names from DATA_DIR
    class_names = sorted([d for d in os.listdir(DATA_DIR) if os.path.isdir(os.path.join(DATA_DIR, d))])

    # Initialize Structures
    activation_vectors = {cls: [] for cls in class_names}   # store activation vectors for each class
    mavs = {}   # store Mean Activation Vector
    weibull_models = {}   # store fitted Weibull parameters per class

    # Compute Activation Vectors
    for cls in class_names:
        cls_path = os.path.join(DATA_DIR, cls)
        img_files = glob.glob(os.path.join(cls_path, "*.png"))[:20]  # Take first 20 images
        for img_file in img_files:
            av = get_activation_vector(img_file)   # Compute activation vector
            activation_vectors[cls].append(av)     # Store all AVs in the activation_vectors

    # Calculate MAVs and Weibull models
    for cls in class_names:
        vectors = np.array(activation_vectors[cls])
        mav = np.mean(vectors, axis=0)
        mavs[cls] = mav   # Compute the Mean Activation Vector (MAV)

        # Compute distance tail and fit Weibull distribution
        dists = [np.linalg.norm(av - mav) for av in vectors]   # Calculate Euclidean distances from each AV to its class MAV
        tail = sorted(dists)[-TAIL_SIZE:]                      # Take the tail (largest TAIL_SIZE distances)
        c, loc, scale = weibull_min.fit(tail, floc=0)          # Fit a Weibull distribution to those distances (with floc=0 → fixes location at 0)
        weibull_models[cls] = (c, scale)                       # Save the (c, scale) parameters

# OpenMax prediction
def compute_openmax_scores(image_bytes, alpha=ALPHA_RANK):
    # Load and preprocess image from bytes
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((IMAGE_SIZE, IMAGE_SIZE))
    x = image.img_to_array(img)
    x_exp = np.expand_dims(x, axis=0)
    x_preprocessed = preprocess_input(x_exp)

    # Get feature activations and model logits
    act = feature_model.predict(x_preprocessed)[0]   # output of the second-last layer (a dense feature vector)
    logits = base_model.predict(x_preprocessed)[0]   # output of the final softmax layer (class scores)
    ranked_classes = np.argsort(logits)[::-1]        # Returns indices of classes sorted in descending order of confidence

    openmax_logits = logits.copy()   # adjusted version of logits after Weibull adjustment
    unknown_score = 0.0              # accumulated probability mass assigned to unknown class

    # Adjust top-k logits using Weibull
    for rank in range(alpha):
        cls_idx = ranked_classes[rank]   # Class index
        cls_name = class_names[cls_idx]  # Class name
        mav = mavs[cls_name]             # Class's MAV (mean activation vector)
        dist = np.linalg.norm(act - mav) # Distance from input activation vector to the MAV

        #Get the Weibull model parameters
        c, scale = weibull_models[cls_name]

        # Compute the CDF score: the class tail distribution
        w_score = weibull_min(c, scale=scale).cdf(dist)

        openmax_logits[cls_idx] *= (1 - w_score)     # Reduce the class’s logit by the open-set probability
        unknown_score += logits[cls_idx] * w_score   # The subtracted portion is added to the unknown class

    # Normalize with Unknown Class
    openmax_logits = np.append(openmax_logits, unknown_score)   # Append the unknown_score as an additional class
    openmax_probs = openmax_logits / np.sum(openmax_logits)     # Normalize the vector to get proper probability distribution

    # Output includes probabilities for known classes and an additional “unknown” class
    return openmax_probs

# =============================================================================== #

# API endpoints

# Prediction API endpoint
@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        contents = await file.read()   # Asynchronously reads the entire image file as bytes
        openmax_probs = compute_openmax_scores(contents)   # Return a probability distribution over all known classes + 1 unknown

        # Format Results
        # Constructs a dictionary mapping each class name to its confidence score
        result = {
            class_names[i]: f"{round(100 * openmax_probs[i], 2)}%"
            for i in range(len(class_names))
        }
        # Include "Unknown" as the last class (index -1 in openmax_probs)
        result["Unknown"] = f"{round(100 * openmax_probs[-1], 2)}%"

        # Determine Predicted Class
        predicted_index = int(np.argmax(openmax_probs))   # Finds the index of the highest probability
        # Determine class name
        predicted_class = class_names[predicted_index] if predicted_index < len(class_names) else "Unknown"

        return JSONResponse(content={
            "predicted_class": predicted_class,
            "confidence": result[predicted_class],
            "all_confidences": result
        })

    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

# Retraining API endpoint
@app.post("/retrain")
async def retrain_model():
    try:
        OBJECTS = len([name for name in os.listdir(DATA_DIR) if os.path.isdir(os.path.join(DATA_DIR, name))])

        # Prepare training and validation datasets
        train_ds = keras_utils.image_dataset_from_directory(
            DATA_DIR, validation_split=0.2, subset='training', seed=123,
            image_size=(IMAGE_SIZE, IMAGE_SIZE), batch_size=BATCHSIZE
        )
        val_ds = keras_utils.image_dataset_from_directory(
            DATA_DIR, validation_split=0.2, subset='validation', seed=123,
            image_size=(IMAGE_SIZE, IMAGE_SIZE), batch_size=BATCHSIZE
        )

        train_ds = train_ds.cache().shuffle(100).prefetch(tf_data.AUTOTUNE)
        val_ds = val_ds.cache().prefetch(tf_data.AUTOTUNE)

        # Load pre-trained VGG16 and freeze layers
        base = VGG16(weights='imagenet', include_top=False, input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3))
        for layer in base.layers:
            layer.trainable = False

        # Add new classification layers
        x = GlobalAveragePooling2D()(base.output)
        x = Dense(512, activation='relu')(x)
        x = Dense(512, activation='relu')(x)
        x = Dense(OBJECTS, activation='softmax')(x)

        model = Model(inputs=base.input, outputs=x)

        # Compile and train
        model.compile(
            loss=keras.losses.SparseCategoricalCrossentropy(),
            optimizer=keras.optimizers.Adam(learning_rate=0.0001),
            metrics=['accuracy']
        )
        model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS)

        model.save(MODEL_PATH)

        # Refresh OpenMax with new weights
        refresh_openmax_pipeline()

        return {"status": "success", "message": "Model retrained and OpenMax updated."}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)


# === INIT CALL ===
refresh_openmax_pipeline()


# Dataset Management Endpoints

@app.post("/upload-image/")
async def upload_image(file: UploadFile = File(...), class_name: str = Form(...)):
    try:
        class_folder = os.path.join(DATA_DIR, class_name)
        os.makedirs(class_folder, exist_ok=True)

        file_path = os.path.join(class_folder, file.filename)
        with open(file_path, "wb") as f:
            f.write(await file.read())

        return {"status": "success", "detail": f"Image saved to {class_folder}"}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/list-all-images/")
def list_all_images():
    result = {}
    try:
        for root, dirs, files in os.walk(DATA_DIR):
            if root == DATA_DIR:
                continue

            folder_name = os.path.basename(root)
            image_files = [f for f in files if f.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.gif'))]
            if image_files:
                result[folder_name] = image_files

        return {"images_by_class": result}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.post("/upload-zip/")
async def upload_zip_files(files: List[UploadFile] = File(...)):
    try:
        for zip_file in files:
            zip_path = f"temp_{zip_file.filename}"
            with open(zip_path, "wb") as f:
                f.write(await zip_file.read())

            extract_folder_name = os.path.splitext(zip_file.filename)[0]
            extract_path = os.path.join(DATA_DIR, extract_folder_name)
            os.makedirs(extract_path, exist_ok=True)

            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(DATA_DIR)

            os.remove(zip_path)

        return {"status": "success", "detail": "ZIP files extracted to Dataset."}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.delete("/remove-folders/")
async def remove_folders(folders: List[str] = Body(...)):
    deleted = []
    not_found = []

    for folder in folders:
        path = os.path.join(DATA_DIR, folder)
        if os.path.isdir(path):
            rmtree(path)
            deleted.append(folder)
        else:
            not_found.append(folder)

    return {
        "status": "completed",
        "deleted": deleted,
        "not_found": not_found
    }

@app.delete("/remove-images/")
async def remove_images(images: List[str] = Body(...)):
    removed = []
    not_found = []

    for image_path in images:
        full_path = os.path.join(DATA_DIR, image_path)
        if os.path.isfile(full_path):
            os.remove(full_path)
            removed.append(image_path)
        else:
            not_found.append(image_path)

    return {
        "status": "completed",
        "removed": removed,
        "not_found": not_found
    }

@app.get("/model-info")
def model_info():
    try:
        last_modified = datetime.fromtimestamp(os.path.getmtime(MODEL_PATH)).isoformat()
        return {"model_last_modified": last_modified}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)