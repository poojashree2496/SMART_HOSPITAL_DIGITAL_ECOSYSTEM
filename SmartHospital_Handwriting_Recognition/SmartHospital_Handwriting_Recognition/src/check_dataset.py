import argparse
from pathlib import Path
import pandas as pd

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--data_csv", required=True)
    p.add_argument("--image_dir", required=True)
    args = p.parse_args()

    df = pd.read_csv(args.data_csv, comment="#").dropna(subset=["image", "text"])
    missing = []
    empty = []

    for _, row in df.iterrows():
        path = Path(args.image_dir) / str(row["image"])
        if not path.exists():
            missing.append(str(path))
        if not str(row["text"]).strip():
            empty.append(str(row["image"]))

    print("Rows:", len(df))
    print("Unique characters:", len(set("".join(df["text"].astype(str)))))
    print("Missing images:", len(missing))
    print("Empty labels:", len(empty))

    if missing:
        print("\nFirst missing images:")
        print("\n".join(missing[:20]))

    if empty:
        print("\nEmpty labels:")
        print("\n".join(empty[:20]))

if __name__ == "__main__":
    main()
