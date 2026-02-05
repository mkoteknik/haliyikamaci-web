import os
from PIL import Image

# Target size for 6.5" Display (iPhone 11 Pro Max, XS Max, etc.)
TARGET_SIZE = (1242, 2688)

# Directory containing the images
SOURCE_DIR = r"d:\Projeler\haliyikamaci-web\uygulamgorsel"
DEST_DIR = os.path.join(SOURCE_DIR, "resized")

if not os.path.exists(DEST_DIR):
    os.makedirs(DEST_DIR)

files = [f for f in os.listdir(SOURCE_DIR) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]

print(f"Found {len(files)} images to resize.")

for filename in files:
    try:
        img_path = os.path.join(SOURCE_DIR, filename)
        img = Image.open(img_path)
        
        # Resize using LANCZOS filter for high quality
        resized_img = img.resize(TARGET_SIZE, Image.Resampling.LANCZOS)
        
        # Save to destination
        save_path = os.path.join(DEST_DIR, filename)
        resized_img.save(save_path)
        print(f"Resized: {filename}")
        
    except Exception as e:
        print(f"Error processing {filename}: {e}")

print("All done! Images saved in 'resized' folder.")
