import pandas as pd

# Load dataset
drug_df = pd.read_csv("Data/drug.csv")

# Shuffle dataset
drug_df = drug_df.sample(frac=1)

# Display top 3 rows
print(drug_df.head(3))

import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OrdinalEncoder, StandardScaler
from sklearn.metrics import accuracy_score, classification_report


# Load Dataset
drug_df = pd.read_csv("Data/drug.csv")

# Shuffle dataset
drug_df = drug_df.sample(frac=1, random_state=42)

print(drug_df.head(3))


# Features and Target
X = drug_df.drop("Drug", axis=1)
y = drug_df["Drug"]


# Train Test Split
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.3,
    random_state=125
)


# Columns
cat_col = ["Sex", "BP", "Cholesterol"]
num_col = ["Age", "Na_to_K"]


# Preprocessing
transform = ColumnTransformer(
    [
        ("encoder", OrdinalEncoder(), cat_col),
        ("num_imputer", SimpleImputer(strategy="median"), num_col),
        ("num_scaler", StandardScaler(), num_col),
    ]
)


# Pipeline with Model
pipe = Pipeline(
    steps=[
        ("preprocessing", transform),
        ("model", RandomForestClassifier(
            n_estimators=100,
            random_state=125
        )),
    ]
)


# Train Model
pipe.fit(X_train, y_train)


# Prediction
y_pred = pipe.predict(X_test)


# Evaluation
print("Accuracy:", accuracy_score(y_test, y_pred))

print(classification_report(y_test, y_pred))

from sklearn.metrics import f1_score, confusion_matrix, ConfusionMatrixDisplay
import matplotlib.pyplot as plt


# Calculate F1 score
f1 = f1_score(y_test, y_pred, average="weighted")


# Save metrics
with open("Results/metrics.txt", "w") as outfile:
    outfile.write(
        f"Accuracy = {accuracy_score(y_test, y_pred):.2f}, "
        f"F1 Score = {f1:.2f}"
    )


# Create confusion matrix
cm = confusion_matrix(
    y_test,
    y_pred,
    labels=pipe.classes_
)

disp = ConfusionMatrixDisplay(
    confusion_matrix=cm,
    display_labels=pipe.classes_
)

disp.plot()

plt.savefig(
    "Results/model_results.png",
    dpi=120
)

print("Metrics and confusion matrix saved successfully!")

import skops.io as sio

# Save trained pipeline
sio.dump(pipe, "Model/drug_pipeline.skops")

print("Pipeline saved successfully!")

sio.load("Model/drug_pipeline.skops", trusted=True)