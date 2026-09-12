import argparse
from pathlib import Path
import csv
import torch

from preprocessing import load_image
from dataset import build_charset
from model import CRNN, greedy_decode
from utils import load_checkpoint

IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".bmp", ".tif", ".tiff"}

def main():
    p = argparse.ArgumentParser()
    group = p.add_mutually_exclusive_group(required=True)
    group.add_argument("--image")
    group.add_argument("--image_dir")
    p.add_argument("--checkpoint", required=True)
    p.add_argument("--output", default="outputs/predictions/predictions.csv")
    args = p.parse_args()

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    ckpt = torch.load(args.checkpoint, map_location=device)
    char_to_idx = ckpt["char_to_idx"]
    idx_to_char = {v: k for k, v in char_to_idx.items()}

    model = CRNN(len(char_to_idx) + 1).to(device)
    load_checkpoint(args.checkpoint, model, device)
    model.eval()

    paths = [Path(args.image)] if args.image else sorted(
        x for x in Path(args.image_dir).iterdir() if x.suffix.lower() in IMAGE_EXTS
    )

    rows = []
    with torch.no_grad():
        for path in paths:
            image = load_image(path, train=False).unsqueeze(0).to(device)
            logits = model(image)
            text = greedy_decode(logits.cpu(), idx_to_char)[0]
            rows.append({"image": str(path), "prediction": text})
            print(f"{path}: {text}")

    if args.image_dir:
        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        with open(args.output, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=["image", "prediction"])
            writer.writeheader()
            writer.writerows(rows)

if __name__ == "__main__":
    main()
