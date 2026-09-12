import torch
import torch.nn as nn

class CRNN(nn.Module):
    """
    CNN + 2-layer BiLSTM + CTC output.
    Input:  [B, 1, 64, 512]
    Output: [T, B, num_classes]
    """
    def __init__(self, num_classes, hidden=256):
        super().__init__()

        self.cnn = nn.Sequential(
            nn.Conv2d(1, 64, 3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2, 2),

            nn.Conv2d(64, 128, 3, padding=1),
            nn.BatchNorm2d(128),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2, 2),

            nn.Conv2d(128, 256, 3, padding=1),
            nn.BatchNorm2d(256),
            nn.ReLU(inplace=True),

            nn.Conv2d(256, 256, 3, padding=1),
            nn.BatchNorm2d(256),
            nn.ReLU(inplace=True),
            nn.MaxPool2d((2, 1), (2, 1)),

            nn.Conv2d(256, 512, 3, padding=1),
            nn.BatchNorm2d(512),
            nn.ReLU(inplace=True),

            nn.Conv2d(512, 512, 3, padding=1),
            nn.BatchNorm2d(512),
            nn.ReLU(inplace=True),
            nn.MaxPool2d((2, 1), (2, 1)),
        )

        self.sequence = nn.LSTM(
            input_size=512 * 4,
            hidden_size=hidden,
            num_layers=2,
            bidirectional=True,
            dropout=0.2,
        )
        self.classifier = nn.Linear(hidden * 2, num_classes)

    def forward(self, x):
        x = self.cnn(x)  # B,C,H,W
        b, c, h, w = x.shape
        x = x.permute(3, 0, 1, 2).contiguous().view(w, b, c * h)
        x, _ = self.sequence(x)
        return self.classifier(x)

def greedy_decode(logits, idx_to_char, blank=0):
    indices = logits.argmax(dim=2).permute(1, 0)  # B,T
    results = []
    for seq in indices:
        prev = blank
        chars = []
        for idx in seq.tolist():
            if idx != blank and idx != prev:
                chars.append(idx_to_char.get(idx, ""))
            prev = idx
        results.append("".join(chars))
    return results
