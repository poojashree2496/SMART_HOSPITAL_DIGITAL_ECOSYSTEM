@echo off
python src\prepare_dataset.py
python src\train.py --data_csv dataset\labels.csv --image_dir dataset\images --epochs 50 --batch_size 16
pause
