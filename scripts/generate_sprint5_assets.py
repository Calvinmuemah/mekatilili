#!/usr/bin/env python3
"""
Generate Levels 2-7 specific 2D assets for Mekatilili wa Menza
Adheres to the official color palette:
  Deep Earth:   #3B2416
  Terracotta:   #B85C38
  Warm Gold:    #D9A441
  Forest Green: #315C3A
  Sand:         #E8D3A8
  Ivory:        #F7F0DE
  Charcoal:     #211C18
"""

import os
import math
from PIL import Image, ImageDraw

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DIR = os.path.join(BASE_DIR, "game", "assets")

C_DEEP_EARTH   = (59, 36, 22, 255)
C_TERRACOTTA   = (184, 92, 56, 255)
C_WARM_GOLD    = (217, 164, 65, 255)
C_FOREST_GREEN = (49, 92, 58, 255)
C_SAND         = (232, 211, 168, 255)
C_IVORY        = (247, 240, 222, 255)
C_CHARCOAL     = (33, 28, 24, 255)

def create_colonial_guard_sheet():
    # 4 directions x 4 animation frames (256 x 256)
    w, h = 64, 64
    sheet = Image.new("RGBA", (w * 4, h * 4), (0, 0, 0, 0))
    directions = ["down", "left", "right", "up"]
    for row, direction in enumerate(directions):
        for col in range(4):
            frame = col
            frame_img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
            d = ImageDraw.Draw(frame_img)
            bob = 1 if frame % 2 == 1 else 0
            leg_off = 3 if frame == 1 else (-3 if frame == 3 else 0)
            
            # Shadow
            d.ellipse([18, 52, 46, 62], fill=(33, 28, 24, 90))
            
            # Dark boots
            d.rectangle([22 + leg_off, 48, 28 + leg_off, 56], fill=C_CHARCOAL)
            d.rectangle([36 - leg_off, 48, 42 - leg_off, 56], fill=C_CHARCOAL)
            
            # Khaki trousers
            d.rectangle([21, 38, 43, 49], fill=(150, 135, 110, 255))
            
            # Khaki colonial tunic
            d.rectangle([20, 22 + bob, 44, 40 + bob], fill=(168, 150, 120, 255))
            # Red/Terracotta belt sash
            d.rectangle([20, 36 + bob, 44, 40 + bob], fill=C_TERRACOTTA)
            # Gold buckle
            d.rectangle([30, 36 + bob, 34, 40 + bob], fill=C_WARM_GOLD)
            
            # Head & Fez / Cap
            skin = (115, 70, 42, 255)
            d.ellipse([25, 9 + bob, 39, 23 + bob], fill=skin)
            
            # Red Fez hat with dark tassel
            d.polygon([(26, 11 + bob), (38, 11 + bob), (36, 4 + bob), (28, 4 + bob)], fill=C_TERRACOTTA)
            d.line([(36, 6 + bob), (40, 12 + bob)], fill=C_CHARCOAL, width=2)
            
            # Rifle / Baton
            if direction in ["down", "left"]:
                d.line([(16, 14 + bob), (16, 52)], fill=C_DEEP_EARTH, width=3)
                d.line([(16, 14 + bob), (16, 24 + bob)], fill=(130, 130, 140, 255), width=2)
            else:
                d.line([(48, 14 + bob), (48, 52)], fill=C_DEEP_EARTH, width=3)
                d.line([(48, 14 + bob), (48, 24 + bob)], fill=(130, 130, 140, 255), width=2)
                
            # Eyes
            if direction == "down":
                d.rectangle([29, 15 + bob, 31, 17 + bob], fill=C_CHARCOAL)
                d.rectangle([34, 15 + bob, 36, 17 + bob], fill=C_CHARCOAL)
            elif direction == "left":
                d.rectangle([27, 15 + bob, 29, 17 + bob], fill=C_CHARCOAL)
            elif direction == "right":
                d.rectangle([36, 15 + bob, 38, 17 + bob], fill=C_CHARCOAL)
                
            sheet.paste(frame_img, (col * w, row * h))
    return sheet

def create_hen_chicks():
    # 64 x 64 mother hen and 3 little chicks
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Hen body shadow
    d.ellipse([14, 46, 46, 56], fill=(33, 28, 24, 80))
    # Hen legs
    d.line([(26, 40), (24, 48)], fill=C_WARM_GOLD, width=2)
    d.line([(32, 40), (32, 48)], fill=C_WARM_GOLD, width=2)
    # Hen body (warm russet plumage)
    d.ellipse([18, 22, 42, 42], fill=C_TERRACOTTA)
    # Wing detail
    d.ellipse([22, 26, 36, 38], fill=C_DEEP_EARTH)
    d.line([(22, 32), (34, 32)], fill=C_WARM_GOLD, width=2)
    # Hen tail feathers
    d.polygon([(14, 26), (20, 24), (18, 36)], fill=C_DEEP_EARTH)
    # Hen head & comb
    d.ellipse([34, 16, 46, 28], fill=C_TERRACOTTA)
    d.polygon([(36, 16), (42, 12), (40, 18)], fill=(220, 40, 40, 255))
    # Beak
    d.polygon([(44, 22), (50, 24), (44, 26)], fill=C_WARM_GOLD)
    # Eye
    d.ellipse([38, 20, 40, 22], fill=C_CHARCOAL)
    
    # 3 little yellow chicks!
    for cx, cy in [(48, 44), (12, 46), (36, 50)]:
        d.ellipse([cx - 4, cy - 4, cx + 4, cy + 4], fill=C_WARM_GOLD)
        d.ellipse([cx + 1, cy - 6, cx + 5, cy - 2], fill=C_WARM_GOLD)
        d.point((cx + 4, cy - 4), fill=C_CHARCOAL)
    return img

def create_notice_board():
    # 64 x 64 wooden post with paper decree
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Shadow
    d.ellipse([20, 52, 44, 62], fill=(33, 28, 24, 80))
    # Wooden post
    d.rectangle([28, 20, 36, 56], fill=C_DEEP_EARTH)
    # Wooden board backing
    d.rounded_rectangle([12, 8, 52, 38], radius=3, fill=(110, 65, 40, 255), outline=C_DEEP_EARTH, width=2)
    # Paper document
    d.rectangle([18, 12, 46, 34], fill=C_IVORY, outline=C_SAND, width=1)
    # Red wax seal
    d.ellipse([38, 24, 44, 30], fill=C_TERRACOTTA)
    # Text lines
    for y in [16, 20, 24, 28]:
        d.line([(22, y), (34, y)], fill=C_CHARCOAL, width=1)
    return img

def create_station_building():
    # 240 x 140 administrative colonial building
    img = Image.new("RGBA", (240, 140), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Ground shadow
    d.rectangle([10, 120, 230, 136], fill=(33, 28, 24, 100))
    # Stone foundation
    d.rectangle([20, 60, 220, 124], fill=(185, 175, 160, 255), outline=C_CHARCOAL, width=3)
    # Brick/stone lines
    for y in [76, 92, 108]:
        d.line([(22, y), (218, y)], fill=(155, 145, 130, 255), width=2)
    # Veranda columns
    for x in [30, 80, 160, 210]:
        d.rectangle([x, 56, x + 10, 124], fill=C_DEEP_EARTH)
    # Central entrance door
    d.rectangle([105, 78, 135, 124], fill=C_DEEP_EARTH, outline=C_CHARCOAL, width=2)
    d.ellipse([128, 102, 132, 106], fill=C_WARM_GOLD) # knob
    # Windows
    for wx in [48, 172]:
        d.rectangle([wx, 74, wx + 24, 98], fill=(90, 125, 140, 255), outline=C_DEEP_EARTH, width=2)
        d.line([(wx + 12, 74), (wx + 12, 98)], fill=C_DEEP_EARTH, width=2)
        d.line([(wx, 86), (wx + 24, 86)], fill=C_DEEP_EARTH, width=2)
    # Corrugated tin / tile roof
    d.polygon([(10, 60), (120, 14), (230, 60)], fill=(165, 80, 60, 255), outline=C_CHARCOAL, width=3)
    for rx in range(30, 210, 18):
        d.line([(rx, 58), (120 + int((rx - 120) * 0.4), 18)], fill=(195, 105, 80, 255), width=2)
    return img

def create_stockade_fence():
    # 64 x 64 stockade fence section
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Pickets
    for x in range(4, 60, 14):
        d.polygon([(x, 56), (x, 16), (x + 5, 8), (x + 10, 16), (x + 10, 56)], fill=(130, 85, 50, 255), outline=C_DEEP_EARTH, width=2)
    # Crossbars
    d.rectangle([0, 24, 64, 30], fill=C_DEEP_EARTH)
    d.rectangle([0, 44, 64, 50], fill=C_DEEP_EARTH)
    return img

def create_colonial_flag():
    # 64 x 96 flag on pole
    img = Image.new("RGBA", (64, 96), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Pole
    d.rectangle([10, 6, 14, 92], fill=(160, 160, 170, 255), outline=C_CHARCOAL, width=1)
    d.ellipse([8, 4, 16, 10], fill=C_WARM_GOLD)
    # Base stand
    d.rectangle([4, 88, 20, 94], fill=C_CHARCOAL)
    # Flag cloth (Union Jack stylized)
    d.rectangle([14, 10, 56, 38], fill=(30, 50, 110, 255), outline=C_CHARCOAL, width=1)
    # White diagonals & cross
    d.line([(14, 10), (56, 38)], fill=C_IVORY, width=4)
    d.line([(14, 38), (56, 10)], fill=C_IVORY, width=4)
    d.line([(35, 10), (35, 38)], fill=C_IVORY, width=8)
    d.line([(14, 24), (56, 24)], fill=C_IVORY, width=8)
    # Red cross
    d.line([(35, 10), (35, 38)], fill=(200, 40, 40, 255), width=4)
    d.line([(14, 24), (56, 24)], fill=(200, 40, 40, 255), width=4)
    return img

def create_kifudu_crowd():
    # 128 x 80 cluster of villagers gathering
    img = Image.new("RGBA", (128, 80), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Shadows
    d.ellipse([10, 60, 118, 76], fill=(33, 28, 24, 90))
    # People silhouettes with traditional khangas, wraps, beadwork
    coords = [
        (24, 36, C_TERRACOTTA, C_SAND),
        (44, 32, C_FOREST_GREEN, C_IVORY),
        (64, 30, C_DEEP_EARTH, C_WARM_GOLD),
        (84, 32, C_TERRACOTTA, C_IVORY),
        (104, 36, C_SAND, C_WARM_GOLD),
        (34, 46, C_DEEP_EARTH, C_TERRACOTTA),
        (54, 44, C_WARM_GOLD, C_IVORY),
        (74, 44, C_TERRACOTTA, C_SAND),
        (94, 46, C_FOREST_GREEN, C_IVORY)
    ]
    for x, y, cloth, accent in coords:
        # Body wrap
        d.ellipse([x - 10, y + 8, x + 10, y + 30], fill=cloth)
        d.arc([x - 8, y + 14, x + 8, y + 24], 0, 180, fill=accent, width=2)
        # Head
        d.ellipse([x - 6, y, x + 6, y + 12], fill=(120, 72, 44, 255))
        # Headwrap / hair
        d.ellipse([x - 6, y, x + 6, y + 6], fill=accent)
    return img

def create_drum():
    # 48 x 48 Kaya sacred drum (Kifudu drum)
    img = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Shadow
    d.ellipse([10, 38, 38, 46], fill=(33, 28, 24, 90))
    # Wooden drum body
    d.polygon([(14, 18), (34, 18), (30, 40), (18, 40)], fill=C_DEEP_EARTH, outline=C_CHARCOAL, width=2)
    # Carved patterns
    d.line([(16, 28), (32, 28)], fill=C_WARM_GOLD, width=2)
    d.line([(17, 34), (31, 34)], fill=C_TERRACOTTA, width=1)
    # Skin head
    d.ellipse([14, 12, 34, 20], fill=C_SAND, outline=C_WARM_GOLD, width=2)
    # Drum pegs
    for px in [16, 24, 32]:
        d.line([(px, 18), (px - 1, 24)], fill=C_IVORY, width=2)
    return img

def main():
    print("Generating Sprint 5 Assets...")
    create_colonial_guard_sheet().save(os.path.join(ASSETS_DIR, "characters", "colonial_guard.png"))
    create_hen_chicks().save(os.path.join(ASSETS_DIR, "environments", "hen_chicks.png"))
    create_notice_board().save(os.path.join(ASSETS_DIR, "environments", "notice_board.png"))
    create_station_building().save(os.path.join(ASSETS_DIR, "environments", "station_building.png"))
    create_stockade_fence().save(os.path.join(ASSETS_DIR, "environments", "stockade_fence.png"))
    create_colonial_flag().save(os.path.join(ASSETS_DIR, "environments", "colonial_flag.png"))
    create_kifudu_crowd().save(os.path.join(ASSETS_DIR, "environments", "kifudu_crowd.png"))
    create_drum().save(os.path.join(ASSETS_DIR, "environments", "drum.png"))
    print("All Sprint 5 Assets generated successfully!")

if __name__ == "__main__":
    main()
