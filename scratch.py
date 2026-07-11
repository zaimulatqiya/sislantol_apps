import base64
import re
import io
from PIL import Image

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

    # Create a solid white background (square) instead of transparent corners
    # Android will automatically mask this square into a circle/squircle
    padding = int(max(img.width, img.height) * 0.15)
    size = max(img.width, img.height) + padding * 2
    
    bg = Image.new('RGBA', (size, size), (255, 255, 255, 255)) # Solid white

    # paste img onto bg centered
    # the 3rd argument (img) acts as a mask to preserve transparency of the logo itself
    offset = ((size - img.width) // 2, (size - img.height) // 2)
    bg.paste(img, offset, img)

    out_path = 'assets/images/app_icon.png'
    bg.save(out_path)
    print(f"Saved to {out_path}")

if __name__ == "__main__":
    create_icon()
