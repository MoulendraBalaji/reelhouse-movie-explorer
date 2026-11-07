from PIL import Image, ImageDraw
import math
import os

def draw_reel(size):
    img = Image.new("RGBA", (size, size), (14, 12, 10, 255))
    draw = ImageDraw.Draw(img)
    
    center = size / 2.0
    outer_radius = size * 0.44
    inner_radius = size * 0.16
    spoke_count = 5
    hole_radius = size * 0.08
    hole_dist = size * 0.28
    
    # Outer ring
    draw.ellipse(
        [center - outer_radius, center - outer_radius, center + outer_radius, center + outer_radius],
        outline=(255, 176, 32, 255),
        width=max(2, int(size * 0.035))
    )
    
    # Perforations / film notches on outer edge
    for i in range(24):
        angle = i * (2 * math.pi / 24)
        nx = center + (outer_radius + size * 0.02) * math.cos(angle)
        ny = center + (outer_radius + size * 0.02) * math.sin(angle)
        nr = max(1.5, size * 0.015)
        draw.ellipse([nx - nr, ny - nr, nx + nr, ny + nr], fill=(255, 176, 32, 180))
        
    # Film spool holes
    for i in range(spoke_count):
        angle = i * (2 * math.pi / spoke_count)
        hx = center + hole_dist * math.cos(angle)
        hy = center + hole_dist * math.sin(angle)
        draw.ellipse(
            [hx - hole_radius, hy - hole_radius, hx + hole_radius, hy + hole_radius],
            fill=(26, 22, 17, 255),
            outline=(255, 176, 32, 255),
            width=max(1, int(size * 0.02))
        )
        
    # Center hub
    draw.ellipse(
        [center - inner_radius, center - inner_radius, center + inner_radius, center + inner_radius],
        fill=(255, 176, 32, 255)
    )
    # Center hole
    chr_radius = inner_radius * 0.4
    draw.ellipse(
        [center - chr_radius, center - chr_radius, center + chr_radius, center + chr_radius],
        fill=(14, 12, 10, 255)
    )
    
    return img

os.makedirs('web/icons', exist_ok=True)
os.makedirs('assets/images', exist_ok=True)

# Generate icons
fav = draw_reel(64)
fav.save('web/favicon.png')

i192 = draw_reel(192)
i192.save('web/icons/Icon-192.png')
i192.save('web/icons/Icon-maskable-192.png')

i512 = draw_reel(512)
i512.save('web/icons/Icon-512.png')
i512.save('web/icons/Icon-maskable-512.png')
i512.save('assets/images/reel_logo.png')

print("Generated all icons successfully!")
