@echo off
python src\predict.py --image_dir dataset\images --checkpoint models\best_model.pth
pause
