import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers # type: ignore
from tensorflow.keras.applications.vgg16 import VGG16 # type: ignore
from tensorflow.keras.models import Model # type: ignore
from tensorflow.keras.layers import Dense,GlobalAveragePooling2D # type: ignore
import os
import matplotlib.pyplot as plt

import numpy as np

# location to the dataset
data_dir = 'GDI'
# Hyperparameters
BATCHSIZE = 16
IMAGE_SIZE = 224 # h, w
EPOCHS = 15
OBJECTS = len([name for name in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, name))])

# Split input data into training data (train dataset = 80% dataset)
train_ds = keras.utils.image_dataset_from_directory(
    data_dir,
    validation_split=0.2,
    subset ='training',
    seed = 123,
    image_size =(IMAGE_SIZE, IMAGE_SIZE),
    batch_size = BATCHSIZE
)
# Split input data into validation data (validation dataset = 20% dataset)
val_ds = keras.utils.image_dataset_from_directory(
    data_dir,
    validation_split =0.2,
    subset = 'validation',
    seed = 123,
    image_size = (IMAGE_SIZE, IMAGE_SIZE),
    batch_size = BATCHSIZE
)
class_names = train_ds.class_names
# Configure the dataset for performance
train_ds = train_ds.cache().shuffle(100).prefetch(buffer_size = tf.data.AUTOTUNE)
val_ds = val_ds.cache().prefetch(buffer_size = tf.data.AUTOTUNE)

# [0, 255]
# [0, 1]
normalizations_layers = layers.Rescaling(1./255)
normalize_ds = train_ds.map(lambda x, y: (normalizations_layers(x), y))
image_batch, label_batch = next(iter(normalize_ds))


# Create a custom image classifier model based on the loaded data. The default model is VGG16
# Load VGG16 with pretrained weights, excluding the top layers
model = VGG16(weights = 'imagenet', include_top = False, input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3))

# Here we freeze the last 4 layers 
# Layers are set to trainable as True by default
for layer in model.layers:
    layer.trainable = False

def topHead(bottom_model):
    top_model = bottom_model.output
    top_model = GlobalAveragePooling2D()(top_model)
    top_model = Dense(512,activation='relu')(top_model)
    top_model = Dense(512,activation='relu')(top_model)
    top_model = Dense(OBJECTS,activation='softmax')(top_model)
    return top_model

Radar_Classify = topHead(model)
model = Model(inputs = model.input, outputs = Radar_Classify)

model.compile(
    loss= keras.losses.SparseCategoricalCrossentropy(),
    optimizer=keras.optimizers.Adam(learning_rate=0.0001),
    metrics = ['accuracy']
    )

history = model.fit(
    train_ds,
    epochs = EPOCHS,
    validation_data = val_ds,
)

# Save the model to file after training
model.save("VGG16_model_GDI.h5")


# Load test dataset for model evaluation
test_ds = keras.utils.image_dataset_from_directory(
    'Test_GDI',
    seed = 123,
    image_size =(IMAGE_SIZE, IMAGE_SIZE),
    batch_size = BATCHSIZE
)


# Confusion matrix
from sklearn.metrics import confusion_matrix, classification_report
import seaborn as sns

# Normalize test dataset
normalization_layer = tf.keras.layers.Rescaling(1./255)
test_ds_normalized = test_ds.map(lambda x, y: (normalization_layer(x), y))

# Generate predictions and collect true/predicted labels
y_true = []
y_pred = []

for images, labels in test_ds:
    preds = model.predict(images)
    y_true.extend(labels.numpy())
    y_pred.extend(np.argmax(preds, axis=1))

# Step 1: Create confusion matrix
cm = confusion_matrix(y_true, y_pred)

# Step 2: Normalize confusion matrix row-wise (by true labels)
cm_normalized = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]  # Normalize by row
cm_percentage = cm_normalized  # Convert to percentage

# Step 3: Plot heatmap with percentages
plt.figure(figsize=(8, 6))
sns.heatmap(cm_percentage, annot=True, fmt='.2f', cmap='Blues',
            xticklabels=class_names, yticklabels=class_names)

plt.xlabel('Predicted Labels')
plt.ylabel('True Labels')
plt.title('Confusion Matrix')
plt.xticks(rotation=90)
plt.yticks(rotation=0)
plt.tight_layout()
plt.show()