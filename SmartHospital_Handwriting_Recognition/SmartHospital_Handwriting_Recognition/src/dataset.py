from pathlib import Path
import pandas as pd
import torch
from torch.utils.data import Dataset
from preprocessing import load_image

class HandwritingDataset(Dataset):
    def __init__(self, csv_path, image_dir, char_to_idx, train=False):
        self.df = pd.read_csv(csv_path, comment="#").dropna(subset=["image", "text"])
        self.image_dir = Path(image_dir)
        self.char_to_idx = char_to_idx
        self.train = train

    def __len__(self):
        return len(self.df)

    def __getitem__(self, idx):
        row = self.df.iloc[idx]
        image = load_image(self.image_dir / str(row["image"]), train=self.train)
        text = str(row["text"])
        target = torch.tensor(
            [self.char_to_idx[c] for c in text if c in self.char_to_idx],
            dtype=torch.long
        )
        return image, target, text, str(row["image"])

def build_charset(csv_paths):
    chars = set()
    for csv_path in csv_paths:
        df = pd.read_csv(csv_path, comment="#").dropna(subset=["text"])
        for text in df["text"].astype(str):
            chars.update(text)
    # 0 is reserved for CTC blank.
    ordered = sorted(chars)
    char_to_idx = {c: i + 1 for i, c in enumerate(ordered)}
    idx_to_char = {i: c for c, i in char_to_idx.items()}
    return char_to_idx, idx_to_char

def collate_fn(batch):
    images, targets, texts, names = zip(*batch)
    images = torch.stack(images)
    lengths = torch.tensor([len(t) for t in targets], dtype=torch.long)
    targets = torch.cat(targets) if sum(lengths).item() else torch.empty(0, dtype=torch.long)
    return images, targets, lengths, list(texts), list(names)
