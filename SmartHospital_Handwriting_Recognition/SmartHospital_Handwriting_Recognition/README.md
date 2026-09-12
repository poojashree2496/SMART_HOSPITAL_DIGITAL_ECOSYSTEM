# SmartHospital Handwritten Prescription Recognition

A custom CRNN-based Handwritten Text Recognition (HTR) pipeline for SmartHospital.

## Architecture

Image -> preprocessing/augmentation -> CNN -> BiLSTM -> Linear -> CTC decoding -> text

The model is designed for line-level handwritten text recognition. A separate medical NLP/NER stage can be added later to extract medicine, dosage, frequency, duration, etc.

## Important

This repository contains the complete trainable model and pipeline, but **not trained weights**. Real accuracy cannot be claimed until the model is trained and evaluated on your dataset.

Do not use raw model output as an autonomous prescribing or medication decision system. Low-confidence results should be manually verified.

## Dataset format

Create:

dataset/images/
    img001.png
    img002.png
    ...

Create `dataset/labels.csv`:

```csv
image,text
img001.png,Take one tablet after food
img002.png,Amoxicillin 500 mg 1-0-1
```

For best evaluation, keep handwriting from people in the test set separate from the training set when possible.

## Install

Python 3.10+ is recommended.

```bash
pip install -r requirements.txt
```

For GPU-enabled PyTorch, install the appropriate PyTorch build for your CUDA version from the official PyTorch instructions before running training.

## Train

```bash
python src/train.py --data_csv dataset/labels.csv --image_dir dataset/images --epochs 50 --batch_size 16
```

The best checkpoint is saved to:

`models/best_model.pth`

## Validate

```bash
python src/validate.py --data_csv dataset/labels.csv --image_dir dataset/images --checkpoint models/best_model.pth
```

For a proper held-out test set, pass a separate CSV containing only test samples.

## Predict one image

```bash
python src/predict.py --image path/to/handwritten_line.png --checkpoint models/best_model.pth
```

## Predict a folder

```bash
python src/predict.py --image_dir path/to/images --checkpoint models/best_model.pth --output outputs/predictions/predictions.csv
```

## Metrics

The pipeline reports:

- Character Error Rate (CER)
- Word Error Rate (WER)
- Character accuracy = 1 - CER
- Word accuracy = 1 - WER
- Exact sequence accuracy

These are more meaningful than ordinary classification accuracy for HTR.

## Recommended next phase

After HTR is working:

1. Add prescription-region/line detection if images contain full prescription pages.
2. Add medical NER for medicine, strength, dosage, frequency, duration and route.
3. Add confidence thresholds and human verification.
4. Test on handwriting from doctors not represented in training.
