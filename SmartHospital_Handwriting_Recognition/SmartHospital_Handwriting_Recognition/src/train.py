import argparse
from pathlib import Path
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, random_split
from tqdm import tqdm

from dataset import HandwritingDataset, build_charset, collate_fn
from model import CRNN, greedy_decode
from metrics import evaluate_pairs
from utils import seed_everything, save_checkpoint

def run_epoch(model, loader, criterion, device, optimizer=None, idx_to_char=None):
    training = optimizer is not None
    model.train(training)
    total_loss = 0.0
    pairs = []

    for images, targets, target_lengths, texts, _ in tqdm(loader, leave=False):
        images = images.to(device)
        targets = targets.to(device)
        logits = model(images)
        log_probs = logits.log_softmax(2)

        input_lengths = torch.full(
            size=(images.size(0),),
            fill_value=logits.size(0),
            dtype=torch.long,
            device=device
        )

        loss = criterion(log_probs, targets, input_lengths, target_lengths.to(device))

        if training:
            optimizer.zero_grad(set_to_none=True)
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 5.0)
            optimizer.step()

        total_loss += loss.item()

        if idx_to_char is not None:
            preds = greedy_decode(logits.detach().cpu(), idx_to_char)
            pairs.extend(zip(texts, preds))

    result = {"loss": total_loss / max(1, len(loader))}
    if pairs:
        result.update(evaluate_pairs(pairs))
    return result

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--data_csv", required=True)
    p.add_argument("--image_dir", required=True)
    p.add_argument("--epochs", type=int, default=50)
    p.add_argument("--batch_size", type=int, default=16)
    p.add_argument("--lr", type=float, default=1e-3)
    p.add_argument("--val_ratio", type=float, default=0.15)
    p.add_argument("--seed", type=int, default=42)
    args = p.parse_args()

    seed_everything(args.seed)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print("Device:", device)

    char_to_idx, idx_to_char = build_charset([args.data_csv])
    if not char_to_idx:
        raise ValueError("No characters found. Put real annotations in dataset/labels.csv.")

    full = HandwritingDataset(args.data_csv, args.image_dir, char_to_idx, train=True)
    n_val = max(1, int(len(full) * args.val_ratio))
    n_train = len(full) - n_val
    train_ds, val_ds = random_split(
        full, [n_train, n_val],
        generator=torch.Generator().manual_seed(args.seed)
    )

    # Validation must not use augmentation.
    val_base = HandwritingDataset(args.data_csv, args.image_dir, char_to_idx, train=False)
    val_ds = torch.utils.data.Subset(val_base, val_ds.indices)

    train_loader = DataLoader(
        train_ds, batch_size=args.batch_size, shuffle=True,
        num_workers=0, collate_fn=collate_fn
    )
    val_loader = DataLoader(
        val_ds, batch_size=args.batch_size, shuffle=False,
        num_workers=0, collate_fn=collate_fn
    )

    model = CRNN(num_classes=len(char_to_idx) + 1).to(device)
    criterion = nn.CTCLoss(blank=0, zero_infinity=True)
    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr, weight_decay=1e-4)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(
        optimizer, mode="min", factor=0.5, patience=3
    )

    Path("models").mkdir(exist_ok=True)
    best = float("inf")

    for epoch in range(1, args.epochs + 1):
        print(f"\nEpoch {epoch}/{args.epochs}")
        train = run_epoch(model, train_loader, criterion, device, optimizer, idx_to_char)
        val = run_epoch(model, val_loader, criterion, device, None, idx_to_char)
        scheduler.step(val["loss"])

        print(
            f"train_loss={train['loss']:.4f} | "
            f"val_loss={val['loss']:.4f} | "
            f"CER={val['CER']:.4f} | WER={val['WER']:.4f} | "
            f"exact={val['exact_sequence_accuracy']:.4f}"
        )

        if val["loss"] < best:
            best = val["loss"]
            save_checkpoint(
                "models/best_model.pth",
                model, optimizer, epoch, best, char_to_idx
            )
            print("Saved best_model.pth")

if __name__ == "__main__":
    main()
