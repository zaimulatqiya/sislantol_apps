import base64
import re
import io
import sys
import subprocess

try:
    from PIL import Image, ImageDraw
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    from PIL import Image, ImageDraw

def create_icon():
    print("Reading SVG...")
    with open('assets/images/logo_1.svg', 'r') as f:
        content = f.read()

    match = re.search(r'base64,([^"]+)', content)
    if not match:
        print("Base64 not found")
        return
        
    b64_data = match.group(1)
    img_data = base64.b64decode(b64_data)

    print("Opening extracted image...")
    img = Image.open(io.BytesIO(img_data)).convert("RGBA")

    # The image might be cropped, let's create a bounding box
    # A circular white background
    # Let's add some padding
    padding = int(max(img.width, img.height) * 0.15)
    size = max(img.width, img.height) + padding * 2
    
    bg = Image.new('RGBA', (size, size), (0,0,0,0))
    draw = ImageDraw.Draw(bg)
    draw.ellipse((0, 0, size-1, size-1), fill="white")

    # paste img onto bg centered
    offset = ((size - img.width) // 2, (size - img.height) // 2)
    bg.paste(img, offset, img)

    out_path = 'assets/images/app_icon.png'
    bg.save(out_path)
    print(f"Saved to {out_path}")

if __name__ == "__main__":
    create_icon()
