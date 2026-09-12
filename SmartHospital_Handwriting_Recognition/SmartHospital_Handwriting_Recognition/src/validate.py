import argparse
import json
from pathlib import Path
import torch
import torch.nn as nn
from torch.utils.data import DataLoader

from dataset import HandwritingDataset, build_charset, collate_fn
from model import CRNN, greedy_decode
from metrics import evaluate_pairs
from utils import load_checkpoint

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--data_csv", required=True)
    p.add_argument("--image_dir", required=True)
    p.add_argument("--checkpoint", required=True)
    p.add_argument("--batch_size", type=int, default=16)
    p.add_argument("--output", default="outputs/metrics/test_metrics.json")
    args = p.parse_args()

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    char_to_idx, idx_to_char = build_charset([args.data_csv])

    ds = HandwritingDataset(args.data_csv, args.image_dir, char_to_idx, train=False)
    loader = DataLoader(ds, batch_size=args.batch_size, shuffle=False, collate_fn=collate_fn)

    model = CRNN(len(char_to_idx) + 1).to(device)
    load_checkpoint(args.checkpoint, model, device)
    model.eval()

    criterion = nn.CTCLoss(blank=0, zero_infinity=True)
    total_loss = 0.0
    pairs = []

    with torch.no_grad():
        for images, targets, target_lengths, texts, names in loader:
            images = images.to(device)
            logits = model(images)
            input_lengths = torch.full(
                (images.size(0),), logits.size(0), dtype=torch.long
            )
            loss = criterion(
                logits.log_softmax(2), targets.to(device),
                input_lengths, target_lengths
            )
            total_loss += loss.item()
            preds = greedy_decode(logits.cpu(), idx_to_char)
            pairs.extend(zip(texts, preds))

    metrics = evaluate_pairs(pairs)
    metrics["loss"] = total_loss / max(1, len(loader))

    print(json.dumps(metrics, indent=2))
    Path(args.output).parent.mkdir(parents=True, exist_ok=True)
    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(metrics, f, indent=2, ensure_ascii=False)

if __name__ == "__main__":
    main()
