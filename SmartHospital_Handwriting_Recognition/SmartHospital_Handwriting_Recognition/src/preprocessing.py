from PIL import Image, ImageOps
import torchvision.transforms as T

IMG_HEIGHT = 64
IMG_WIDTH = 512

train_transform = T.Compose([
    T.Grayscale(num_output_channels=1),
    T.Resize((IMG_HEIGHT, IMG_WIDTH)),
    T.RandomAffine(
        degrees=2,
        translate=(0.02, 0.04),
        scale=(0.95, 1.05),
        shear=2,
        fill=255,
    ),
    T.ToTensor(),
    T.Normalize((0.5,), (0.5,))
])

eval_transform = T.Compose([
    T.Grayscale(num_output_channels=1),
    T.Resize((IMG_HEIGHT, IMG_WIDTH)),
    T.ToTensor(),
    T.Normalize((0.5,), (0.5,))
])

def load_image(path, train=False):
    image = Image.open(path).convert("L")
    # White-background normalization helps when scans/photos have inverted polarity.
    image = ImageOps.autocontrast(image)
    return (train_transform if train else eval_transform)(image)
