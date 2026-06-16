import os
import json
import joblib
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

np.random.seed(42)

BASE_DIR = "/home/jovyan/work"
DATA_DIR = os.path.join(BASE_DIR, "data")
MODELS_DIR = os.path.join(BASE_DIR, "models")
REPORTS_DIR = os.path.join(BASE_DIR, "reports")

os.makedirs(DATA_DIR, exist_ok=True)
os.makedirs(MODELS_DIR, exist_ok=True)
os.makedirs(REPORTS_DIR, exist_ok=True)

print("ML container training workflow started")
print(f"Working directory: {os.getcwd()}")

X, y = make_classification(
    n_samples=1000,
    n_features=20,
    n_informative=15,
    n_redundant=5,
    n_classes=2,
    random_state=42
)

feature_names = [f"feature_{i}" for i in range(X.shape[1])]
df = pd.DataFrame(X, columns=feature_names)
df["target"] = y

dataset_path = os.path.join(DATA_DIR, "synthetic_classification_dataset.csv")
df.to_csv(dataset_path, index=False)

print(f"Dataset saved to: {dataset_path}")
print(f"Dataset shape: {df.shape}")

plt.figure(figsize=(8, 5))
df["target"].value_counts().plot(kind="bar")
plt.title("Target Distribution")
plt.xlabel("Class")
plt.ylabel("Count")
plt.tight_layout()
plt.savefig(os.path.join(REPORTS_DIR, "target-distribution.png"))
plt.close()

plt.figure(figsize=(10, 8))
correlation_matrix = df.iloc[:, :10].corr()
sns.heatmap(correlation_matrix, annot=True, center=0)
plt.title("Feature Correlation Heatmap")
plt.tight_layout()
plt.savefig(os.path.join(REPORTS_DIR, "feature-correlation-heatmap.png"))
plt.close()

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

rf_model = RandomForestClassifier(
    n_estimators=100,
    random_state=42,
    max_depth=10
)

print("Training model...")
rf_model.fit(X_train, y_train)
print("Model training completed")

y_pred = rf_model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)

classification_report_text = classification_report(y_test, y_pred)

with open(os.path.join(REPORTS_DIR, "classification-report.txt"), "w") as f:
    f.write(classification_report_text)

cm = confusion_matrix(y_test, y_pred)

plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt="d")
plt.title("Confusion Matrix")
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.tight_layout()
plt.savefig(os.path.join(REPORTS_DIR, "confusion-matrix.png"))
plt.close()

feature_importance = pd.DataFrame({
    "feature": feature_names,
    "importance": rf_model.feature_importances_
}).sort_values("importance", ascending=False)

feature_importance.to_csv(
    os.path.join(REPORTS_DIR, "feature-importance.csv"),
    index=False
)

plt.figure(figsize=(10, 6))
sns.barplot(data=feature_importance.head(10), x="importance", y="feature")
plt.title("Top 10 Feature Importances")
plt.xlabel("Importance")
plt.tight_layout()
plt.savefig(os.path.join(REPORTS_DIR, "feature-importance.png"))
plt.close()

model_path = os.path.join(MODELS_DIR, "random-forest-classifier.joblib")
joblib.dump(rf_model, model_path)

metadata = {
    "model_type": "RandomForestClassifier",
    "accuracy": float(accuracy),
    "n_features": int(X.shape[1]),
    "n_samples_total": int(X.shape[0]),
    "n_samples_train": int(X_train.shape[0]),
    "n_samples_test": int(X_test.shape[0]),
    "feature_names": feature_names,
    "model_path": model_path
}

metadata_path = os.path.join(MODELS_DIR, "model-metadata.json")
with open(metadata_path, "w") as f:
    json.dump(metadata, f, indent=2)

loaded_model = joblib.load(model_path)
loaded_accuracy = accuracy_score(y_test, loaded_model.predict(X_test))

validation = {
    "loaded_model_accuracy": float(loaded_accuracy),
    "original_accuracy": float(accuracy),
    "accuracy_match": bool(abs(loaded_accuracy - accuracy) < 1e-10),
    "sample_predictions": loaded_model.predict(X_test[:5]).tolist(),
    "sample_actual_values": y_test[:5].tolist()
}

with open(os.path.join(REPORTS_DIR, "model-load-validation.json"), "w") as f:
    json.dump(validation, f, indent=2)

print(f"Model accuracy: {accuracy:.4f}")
print(f"Model saved to: {model_path}")
print(f"Metadata saved to: {metadata_path}")
print("Model load validation completed")
