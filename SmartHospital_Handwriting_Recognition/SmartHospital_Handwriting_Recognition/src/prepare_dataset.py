"""Render prescription PDFs and create a reviewable labels.csv file."""

import argparse
import csv
import re
from pathlib import Path

import fitz


DATE_SUFFIX = re.compile(r"\s*\([^)]*\)(?:\s*\(\d+\))?$")


def provisional_label(pdf_path: Path) -> str:
    """Use the filename's case name until a human enters exact transcription."""
    return DATE_SUFFIX.sub("", pdf_path.stem).strip()


def render_pdfs(source_dir: Path, image_dir: Path, labels_path: Path, dpi: int) -> int:
    image_dir.mkdir(parents=True, exist_ok=True)
    labels_path.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    scale = dpi / 72
    matrix = fitz.Matrix(scale, scale)

    for pdf_path in sorted(source_dir.glob("*.pdf")):
        document = fitz.open(pdf_path)
        try:
            label = provisional_label(pdf_path)
            for page_number, page in enumerate(document, start=1):
                image_name = f"{pdf_path.stem}_{page_number:03d}.png"
                image_path = image_dir / image_name
                pixmap = page.get_pixmap(matrix=matrix, alpha=False)
                pixmap.save(str(image_path))
                rows.append({
                    "image": image_name,
                    "text": label,
                    "source_pdf": pdf_path.name,
                    "page": page_number,
                    "label_status": "PROVISIONAL_FILENAME_LABEL",
                })
        finally:
            document.close()

    with labels_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["image", "text", "source_pdf", "page", "label_status"],
        )
        writer.writeheader()
        writer.writerows(rows)
    return len(rows)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source_dir", default="dataset/Prescriptions - Dataset")
    parser.add_argument("--image_dir", default="dataset/images")
    parser.add_argument("--labels", default="dataset/labels.csv")
    parser.add_argument("--dpi", type=int, default=200)
    args = parser.parse_args()

    count = render_pdfs(
        Path(args.source_dir), Path(args.image_dir), Path(args.labels), args.dpi
    )
    print(f"Rendered {count} page(s) and wrote {args.labels}.")
    print("Replace provisional text labels with exact page transcription before evaluation.")


if __name__ == "__main__":
    main()