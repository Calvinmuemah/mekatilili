#!/usr/bin/env python3
"""
Generate stylized 2D game assets for Mekatilili wa Menza game
adhering strictly to the color palette:
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
from PIL import Image, ImageDraw, ImageFilter

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GAME_DIR = os.path.join(BASE_DIR, "game")
ASSETS_DIR = os.path.join(GAME_DIR, "assets")

# Palette
C_DEEP_EARTH   = (59, 36, 22, 255)
C_TERRACOTTA   = (184, 92, 56, 255)
C_WARM_GOLD    = (217, 164, 65, 255)
C_FOREST_GREEN = (49, 92, 58, 255)
C_SAND         = (232, 211, 168, 255)
C_IVORY        = (247, 240, 222, 255)
C_CHARCOAL     = (33, 28, 24, 255)

def ensure_dirs():
    for d in [
        "characters", "characters/portraits",
        "environments", "icons", "ui", "audio"
    ]:
        os.makedirs(os.path.join(ASSETS_DIR, d), exist_ok=True)

def draw_mekatilili_sprite(w=64, h=64, frame=0, direction="down"):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Shadow
    d.ellipse([16, 52, 48, 62], fill=(33, 28, 24, 90))
    
    # Bobbing for animation
    bob = 1 if frame % 2 == 1 else 0
    leg_offset = 3 if frame == 1 else (-3 if frame == 3 else 0)
    
    # Feet / Sandals
    d.rectangle([22 + leg_offset, 50, 28 + leg_offset, 56], fill=C_DEEP_EARTH)
    d.rectangle([36 - leg_offset, 50, 42 - leg_offset, 56], fill=C_DEEP_EARTH)
    
    # Giriama traditional Kishutu/Khanga skirt (Warm Terracotta with Sand & Gold patterns)
    d.polygon([
        (20, 34 + bob), (44, 34 + bob),
        (48, 51), (16, 51)
    ], fill=C_TERRACOTTA)
    # Pattern stripe
    d.line([(18, 44), (46, 44)], fill=C_WARM_GOLD, width=2)
    d.line([(17, 48), (47, 48)], fill=C_SAND, width=1)
    
    # Torso (Traditional wrap / beadwork)
    d.rectangle([23, 22 + bob, 41, 35 + bob], fill=C_TERRACOTTA)
    # Beaded necklaces (Uhanga - multi-strand gold and ivory beads)
    d.arc([25, 20 + bob, 39, 30 + bob], start=0, end=180, fill=C_WARM_GOLD, width=2)
    d.arc([24, 23 + bob, 40, 33 + bob], start=0, end=180, fill=C_IVORY, width=1)
    
    # Head & Neck
    d.rectangle([29, 18 + bob, 35, 23 + bob], fill=(130, 80, 50, 255))
    d.ellipse([24, 8 + bob, 40, 22 + bob], fill=(120, 72, 44, 255)) # Warm deep skin tone
    
    # Traditional headwrap (Kilemba - Sand with gold border)
    d.polygon([
        (22, 10 + bob), (42, 10 + bob),
        (38, 5 + bob), (26, 5 + bob)
    ], fill=C_SAND)
    d.line([(22, 10 + bob), (42, 10 + bob)], fill=C_WARM_GOLD, width=2)
    
    # Face details (eyes, noble expression)
    if direction in ["down", "left", "right"]:
        if direction == "down":
            d.rectangle([28, 14 + bob, 30, 16 + bob], fill=C_CHARCOAL)
            d.rectangle([34, 14 + bob, 36, 16 + bob], fill=C_CHARCOAL)
            d.point((29, 14 + bob), fill=C_IVORY)
            d.point((35, 14 + bob), fill=C_IVORY)
        elif direction == "left":
            d.rectangle([25, 14 + bob, 27, 16 + bob], fill=C_CHARCOAL)
            d.point((26, 14 + bob), fill=C_IVORY)
        elif direction == "right":
            d.rectangle([37, 14 + bob, 39, 16 + bob], fill=C_CHARCOAL)
            d.point((38, 14 + bob), fill=C_IVORY)
            
    # Arms / staff of leadership
    if direction == "down":
        d.line([(18, 24 + bob), (21, 38 + bob)], fill=(120, 72, 44, 255), width=3)
        # Leadership walking staff (Bakora)
        d.line([(16, 12 + bob), (16, 56)], fill=C_WARM_GOLD, width=2)
        d.ellipse([14, 10 + bob, 18, 14 + bob], fill=C_WARM_GOLD)
        d.line([(43, 24 + bob), (45, 38 + bob)], fill=(120, 72, 44, 255), width=3)
        
    return img

def create_character_sheet(char_type="mekatilili"):
    # 4 rows: Down, Up, Left, Right; 4 frames per row -> 256x256 sheet
    sheet = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    directions = ["down", "up", "left", "right"]
    
    for row, direct in enumerate(directions):
        for col in range(4):
            if char_type == "mekatilili":
                frame_img = draw_mekatilili_sprite(64, 64, frame=col, direction=direct)
            else:
                frame_img = draw_npc_sprite(64, 64, char_type=char_type, frame=col, direction=direct)
            sheet.paste(frame_img, (col * 64, row * 64))
            
    return sheet

def draw_npc_sprite(w=64, h=64, char_type="elder", frame=0, direction="down"):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    bob = 1 if frame % 2 == 1 else 0
    leg_offset = 2 if frame == 1 else (-2 if frame == 3 else 0)
    
    # Shadow
    d.ellipse([16, 52, 48, 62], fill=(33, 28, 24, 90))
    
    skin = (115, 68, 42, 255)
    cloth_primary = C_FOREST_GREEN if char_type == "elder" else (
        C_SAND if char_type == "wanje" else (
            C_DEEP_EARTH if char_type == "villager" else (
                C_TERRACOTTA if char_type == "warrior" else (80, 80, 110, 255) # colonial
            )
        )
    )
    
    # Feet
    d.rectangle([23 + leg_offset, 50, 28 + leg_offset, 56], fill=C_DEEP_EARTH)
    d.rectangle([36 - leg_offset, 41, 41 - leg_offset, 56], fill=C_DEEP_EARTH)
    
    # Body
    d.rectangle([21, 24 + bob, 43, 50], fill=cloth_primary)
    
    # Elder white beard or warrior band
    if char_type == "elder":
        # White cloth mantle over shoulder
        d.polygon([(21, 24 + bob), (35, 24 + bob), (28, 48)], fill=C_IVORY)
    elif char_type == "wanje":
        # Medicine pouch / gourd strap
        d.line([(24, 24 + bob), (40, 42 + bob)], fill=C_WARM_GOLD, width=3)
        d.ellipse([36, 38 + bob, 44, 46 + bob], fill=C_TERRACOTTA)
    elif char_type == "warrior":
        # Quiver / spear
        d.line([(18, 12), (18, 54)], fill=C_WARM_GOLD, width=2)
        d.polygon([(16, 12), (20, 12), (18, 6)], fill=C_SAND)
    elif char_type == "colonial":
        # Colonial khaki tunic & brass buttons
        d.rectangle([21, 24 + bob, 43, 46], fill=(160, 145, 120, 255))
        d.line([(32, 26), (32, 44)], fill=C_WARM_GOLD, width=2)
        
    # Head & Face
    d.ellipse([24, 9 + bob, 40, 23 + bob], fill=skin if char_type != "colonial" else (210, 180, 160, 255))
    
    if char_type == "elder":
        # Venerable white beard
        d.polygon([(28, 18 + bob), (36, 18 + bob), (32, 26 + bob)], fill=C_IVORY)
        d.rectangle([27, 8 + bob, 37, 12 + bob], fill=C_IVORY) # White hair
    elif char_type == "colonial":
        # Pith helmet
        d.ellipse([21, 5 + bob, 43, 13 + bob], fill=C_IVORY)
        d.rectangle([25, 7 + bob, 39, 14 + bob], fill=C_IVORY)
    elif char_type == "warrior":
        # Red headband
        d.line([(24, 11 + bob), (40, 11 + bob)], fill=C_TERRACOTTA, width=2)
        
    # Eyes
    if direction == "down":
        eye_color = C_CHARCOAL
        d.rectangle([28, 15 + bob, 30, 17 + bob], fill=eye_color)
        d.rectangle([34, 15 + bob, 36, 17 + bob], fill=eye_color)
        
    return img

def create_portrait(name="mekatilili"):
    size = 128
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Warm circular background frame with gold border
    d.ellipse([8, 8, 120, 120], fill=C_DEEP_EARTH)
    d.ellipse([8, 8, 120, 120], outline=C_WARM_GOLD, width=3)
    
    if name == "mekatilili":
        # Face
        d.ellipse([44, 34, 84, 76], fill=(120, 72, 44, 255))
        # Headwrap
        d.polygon([(36, 36), (92, 36), (82, 18), (46, 18)], fill=C_SAND)
        d.line([(36, 36), (92, 36)], fill=C_WARM_GOLD, width=3)
        # Shoulders & Khanga
        d.polygon([(20, 118), (108, 118), (86, 76), (42, 76)], fill=C_TERRACOTTA)
        # Beaded necklaces
        d.arc([46, 68, 82, 90], 0, 180, fill=C_WARM_GOLD, width=3)
        d.arc([43, 73, 85, 96], 0, 180, fill=C_IVORY, width=2)
        # Eyes
        d.ellipse([50, 48, 56, 54], fill=C_IVORY)
        d.ellipse([52, 50, 56, 54], fill=C_CHARCOAL)
        d.ellipse([72, 48, 78, 54], fill=C_IVORY)
        d.ellipse([72, 50, 76, 54], fill=C_CHARCOAL)
        # Calm determined smile
        d.arc([56, 58, 72, 68], 20, 160, fill=C_DEEP_EARTH, width=2)
    elif name == "elder":
        # Mzee Fondo
        d.ellipse([44, 34, 84, 76], fill=(110, 65, 40, 255))
        d.polygon([(38, 118), (90, 118), (84, 78), (44, 78)], fill=C_FOREST_GREEN)
        d.polygon([(46, 78), (82, 78), (64, 118)], fill=C_IVORY)
        # White hair and full white beard
        d.arc([42, 28, 86, 60], 180, 360, fill=C_IVORY, width=6)
        d.polygon([(50, 62), (78, 62), (64, 86)], fill=C_IVORY)
        d.ellipse([50, 46, 56, 52], fill=C_CHARCOAL)
        d.ellipse([72, 46, 78, 52], fill=C_CHARCOAL)
    elif name == "wanje":
        # Wanje wa Mwadorikola
        d.ellipse([44, 34, 84, 76], fill=(115, 70, 42, 255))
        d.polygon([(26, 118), (102, 118), (84, 76), (44, 76)], fill=C_SAND)
        d.line([(34, 80), (88, 118)], fill=C_WARM_GOLD, width=4)
        # Healer bead headpiece
        d.line([(44, 36), (84, 36)], fill=C_WARM_GOLD, width=3)
        d.ellipse([61, 33, 67, 39], fill=C_TERRACOTTA)
        d.ellipse([50, 48, 56, 54], fill=C_CHARCOAL)
        d.ellipse([72, 48, 78, 54], fill=C_CHARCOAL)
    elif name == "nyevu":
        # Villager Nyevu
        d.ellipse([44, 34, 84, 76], fill=(125, 76, 46, 255))
        d.polygon([(30, 118), (98, 118), (84, 76), (44, 76)], fill=C_TERRACOTTA)
        d.ellipse([46, 22, 82, 38], fill=C_WARM_GOLD)
        d.ellipse([50, 48, 56, 54], fill=C_CHARCOAL)
        d.ellipse([72, 48, 78, 54], fill=C_CHARCOAL)
    elif name == "charo":
        # Young warrior Charo
        d.ellipse([44, 34, 84, 76], fill=(120, 72, 44, 255))
        d.polygon([(30, 118), (98, 118), (84, 76), (44, 76)], fill=C_DEEP_EARTH)
        d.line([(44, 36), (84, 36)], fill=C_TERRACOTTA, width=4)
        d.ellipse([50, 48, 56, 54], fill=C_CHARCOAL)
        d.ellipse([72, 48, 78, 54], fill=C_CHARCOAL)
    elif name == "champion":
        # Arthur Champion
        d.ellipse([44, 34, 84, 76], fill=(225, 195, 175, 255))
        d.polygon([(26, 118), (102, 118), (86, 76), (42, 76)], fill=(160, 145, 120, 255))
        d.line([(64, 76), (64, 118)], fill=C_WARM_GOLD, width=3)
        # Colonial helmet
        d.polygon([(34, 36), (94, 36), (82, 16), (46, 16)], fill=C_IVORY)
        d.ellipse([30, 32, 98, 42], fill=C_IVORY)
        d.ellipse([50, 50, 56, 54], fill=(40, 70, 120, 255))
        d.ellipse([72, 50, 78, 54], fill=(40, 70, 120, 255))
        # Stern colonial mustache
        d.rectangle([54, 62, 74, 66], fill=(130, 100, 80, 255))

    return img

def create_environment_assets():
    # 1. Giriama Thatched Hut (Nyumba ya vidzo) 128x128
    hut = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    d = ImageDraw.Draw(hut)
    # Shadow
    d.ellipse([10, 95, 118, 125], fill=(33, 28, 24, 110))
    # Mud / Earth Wall Base
    d.rectangle([28, 65, 100, 110], fill=C_TERRACOTTA)
    # Wood frame lines
    for x in range(35, 95, 12):
        d.line([(x, 65), (x, 110)], fill=C_DEEP_EARTH, width=2)
    # Dark Doorway
    d.rounded_rectangle([52, 75, 76, 110], radius=8, fill=C_CHARCOAL)
    # Traditional steep conical makuti/thatch roof
    d.polygon([(14, 72), (64, 12), (114, 72)], fill=C_SAND)
    # Thatch layers
    for y, inset in [(55, 6), (40, 14), (26, 24)]:
        d.line([(14 + inset, y), (114 - inset, y)], fill=C_WARM_GOLD, width=3)
        d.line([(14 + inset, y + 2), (114 - inset, y + 2)], fill=C_DEEP_EARTH, width=1)
    hut.save(os.path.join(ASSETS_DIR, "environments", "hut_large.png"))
    
    # 2. Sacred Baobab Tree 160x160
    tree = Image.new("RGBA", (160, 160), (0, 0, 0, 0))
    d = ImageDraw.Draw(tree)
    # Shadow
    d.ellipse([20, 130, 140, 155], fill=(33, 28, 24, 100))
    # Massive trunk
    d.polygon([
        (55, 145), (105, 145),
        (96, 75), (118, 48),
        (88, 55), (80, 35),
        (72, 55), (42, 48),
        (64, 75)
    ], fill=(95, 65, 45, 255))
    # Bark texture
    for y in range(80, 140, 10):
        d.line([(62, y), (98, y)], fill=C_DEEP_EARTH, width=2)
    # Leafy canopy clusters
    for cx, cy, r in [(50, 42, 28), (80, 30, 32), (110, 42, 28), (80, 52, 26)]:
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=C_FOREST_GREEN)
        d.ellipse([cx - r + 4, cy - r + 4, cx + r - 4, cy + r - 4], outline=C_WARM_GOLD, width=1)
    tree.save(os.path.join(ASSETS_DIR, "environments", "baobab_tree.png"))
    
    # 3. Coconut Palm Tree 96x160
    palm = Image.new("RGBA", (96, 160), (0, 0, 0, 0))
    d = ImageDraw.Draw(palm)
    d.ellipse([20, 145, 76, 158], fill=(33, 28, 24, 100))
    # Curved trunk
    trunk_pts = [(48, 150), (46, 120), (42, 90), (36, 60), (32, 35)]
    for i in range(len(trunk_pts) - 1):
        d.line([trunk_pts[i], trunk_pts[i+1]], fill=(120, 85, 55, 255), width=8)
        d.line([trunk_pts[i], trunk_pts[i+1]], fill=C_DEEP_EARTH, width=2)
    # Coconuts
    d.ellipse([27, 34, 35, 42], fill=C_DEEP_EARTH)
    d.ellipse([34, 32, 42, 40], fill=C_DEEP_EARTH)
    # Fronds
    d.arc([0, 10, 60, 60], 160, 320, fill=C_FOREST_GREEN, width=4)
    d.arc([20, 10, 90, 60], 220, 360, fill=C_FOREST_GREEN, width=4)
    d.arc([5, 20, 55, 80], 170, 330, fill=C_FOREST_GREEN, width=4)
    d.arc([30, 20, 85, 80], 210, 350, fill=C_FOREST_GREEN, width=4)
    palm.save(os.path.join(ASSETS_DIR, "environments", "palm_tree.png"))
    
    # 4. Shamba Cassava & Crop Patch 64x64
    crop = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(crop)
    d.ellipse([10, 35, 54, 58], fill=(140, 85, 45, 200)) # Soil mound
    # Green cassava leaves
    for angle in [30, 60, 90, 120, 150]:
        rad = math.radians(angle)
        ex = 32 + int(math.cos(rad) * 22)
        ey = 40 - int(math.sin(rad) * 22)
        d.line([(32, 40), (ex, ey)], fill=C_FOREST_GREEN, width=3)
        d.ellipse([ex - 4, ey - 4, ex + 4, ey + 4], fill=C_FOREST_GREEN)
    crop.save(os.path.join(ASSETS_DIR, "environments", "cassava_patch.png"))
    
    # 5. Council Fire Pit 64x64
    fire = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(fire)
    # Shadow and ash
    d.ellipse([12, 28, 52, 54], fill=C_CHARCOAL)
    # Stone ring
    for i in range(8):
        ang = i * (2 * math.pi / 8)
        sx = 32 + int(math.cos(ang) * 16)
        sy = 40 + int(math.sin(ang) * 9)
        d.ellipse([sx - 4, sy - 3, sx + 4, sy + 3], fill=C_SAND, outline=C_DEEP_EARTH)
    # Fire flames
    d.polygon([(26, 40), (32, 18), (38, 40)], fill=C_TERRACOTTA)
    d.polygon([(28, 40), (32, 24), (36, 40)], fill=C_WARM_GOLD)
    fire.save(os.path.join(ASSETS_DIR, "environments", "fire_pit.png"))

def create_items_and_icons():
    # 1. Calabash / Sacred Gourd 64x64
    calabash = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(calabash)
    d.ellipse([16, 50, 48, 60], fill=(33, 28, 24, 90))
    # Bottom bowl
    d.ellipse([18, 26, 46, 54], fill=C_WARM_GOLD, outline=C_DEEP_EARTH, width=2)
    # Waist & top bowl
    d.ellipse([24, 14, 40, 32], fill=C_WARM_GOLD, outline=C_DEEP_EARTH, width=2)
    # Stopper & cord
    d.rectangle([29, 8, 35, 14], fill=C_TERRACOTTA)
    d.line([(22, 30), (42, 30)], fill=C_IVORY, width=2)
    calabash.save(os.path.join(ASSETS_DIR, "icons", "calabash.png"))
    
    # 2. Kaya Herb Pouch 64x64
    pouch = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(pouch)
    d.ellipse([16, 50, 48, 60], fill=(33, 28, 24, 90))
    d.rounded_rectangle([18, 22, 46, 52], radius=10, fill=C_TERRACOTTA, outline=C_DEEP_EARTH, width=2)
    d.line([(20, 26), (44, 26)], fill=C_WARM_GOLD, width=3)
    # Medicinal sprig poking out
    d.line([(28, 24), (24, 12)], fill=C_FOREST_GREEN, width=3)
    d.ellipse([20, 10, 26, 16], fill=C_FOREST_GREEN)
    d.ellipse([34, 12, 40, 18], fill=C_FOREST_GREEN)
    pouch.save(os.path.join(ASSETS_DIR, "icons", "herb_pouch.png"))
    
    # 3. Colonial Tax Decree 64x64
    decree = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(decree)
    d.rectangle([14, 10, 50, 54], fill=C_IVORY, outline=C_DEEP_EARTH, width=2)
    # Colonial red seal
    d.ellipse([27, 40, 37, 50], fill=C_TERRACOTTA)
    # Decree text lines
    for y in [18, 24, 30, 36]:
        d.line([(18, y), (46, y)], fill=C_CHARCOAL, width=2)
    decree.save(os.path.join(ASSETS_DIR, "icons", "colonial_decree.png"))
    
    # 4. Quest & UI markers
    # Quest marker 48x48
    qm = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(qm)
    d.ellipse([6, 6, 42, 42], fill=C_WARM_GOLD, outline=C_DEEP_EARTH, width=2)
    d.rectangle([22, 12, 26, 26], fill=C_DEEP_EARTH)
    d.rectangle([22, 30, 26, 34], fill=C_DEEP_EARTH)
    qm.save(os.path.join(ASSETS_DIR, "icons", "quest_marker.png"))
    
    # Talk marker 48x48
    tm = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(tm)
    d.rounded_rectangle([6, 8, 42, 34], radius=6, fill=C_SAND, outline=C_DEEP_EARTH, width=2)
    d.polygon([(16, 34), (24, 34), (16, 42)], fill=C_SAND)
    d.line([(16, 34), (16, 42), (24, 34)], fill=C_DEEP_EARTH, width=2)
    for x in [14, 24, 34]:
        d.ellipse([x - 2, 19, x + 2, 23], fill=C_DEEP_EARTH)
    tm.save(os.path.join(ASSETS_DIR, "icons", "talk_marker.png"))

def create_ui_assets():
    # 1. Main Menu Background (1280x720)
    bg = Image.new("RGBA", (1280, 720), (0, 0, 0, 255))
    d = ImageDraw.Draw(bg)
    # Sunset gradient from Warm Gold / Terracotta to Deep Earth
    for y in range(720):
        t = y / 720.0
        # Sky: Terracotta -> Warm Gold -> Deep Sand -> Earth
        r = int(184 * (1 - t*0.5) + 59 * (t*0.5))
        g = int(92 * (1 - t*0.6) + 36 * (t*0.6))
        b = int(56 * (1 - t*0.8) + 22 * (t*0.8))
        d.line([(0, y), (1280, y)], fill=(r, g, b, 255))
        
    # Large warm sun on horizon
    d.ellipse([540, 220, 740, 420], fill=(247, 210, 110, 180))
    
    # Silhouetted coastal hills and palms
    d.polygon([(0, 520), (320, 460), (740, 510), (1280, 470), (1280, 720), (0, 720)], fill=(45, 28, 18, 255))
    d.polygon([(0, 570), (450, 530), (920, 560), (1280, 540), (1280, 720), (0, 720)], fill=C_DEEP_EARTH)
    
    # Silhouetted Baobab on the right
    d.polygon([(1000, 720), (1050, 500), (1030, 420), (1080, 410), (1070, 720)], fill=C_CHARCOAL)
    for bx, by, br in [(980, 420, 60), (1050, 390, 70), (1110, 430, 55)]:
        d.ellipse([bx - br, by - br, bx + br, by + br], fill=C_CHARCOAL)
        
    bg.save(os.path.join(ASSETS_DIR, "ui", "menu_background.png"))
    
    # 2. Splash screen emblem (256x256)
    emblem = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    d = ImageDraw.Draw(emblem)
    d.ellipse([20, 20, 236, 236], fill=C_DEEP_EARTH, outline=C_WARM_GOLD, width=6)
    d.ellipse([34, 34, 222, 222], outline=C_SAND, width=2)
    # Sacred sun & Kaya palm motif
    d.arc([60, 60, 196, 196], 30, 150, fill=C_WARM_GOLD, width=4)
    # Central rising bird/flame motif
    d.polygon([(128, 60), (150, 130), (128, 115), (106, 130)], fill=C_WARM_GOLD)
    d.polygon([(128, 115), (160, 180), (128, 165), (96, 180)], fill=C_TERRACOTTA)
    emblem.save(os.path.join(ASSETS_DIR, "ui", "splash_emblem.png"))
    
    # 3. Virtual Joystick assets
    # Base 128x128
    j_base = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    d = ImageDraw.Draw(j_base)
    d.ellipse([6, 6, 122, 122], fill=(59, 36, 22, 130), outline=(217, 164, 65, 200), width=3)
    d.ellipse([48, 48, 80, 80], outline=(232, 211, 168, 120), width=1)
    j_base.save(os.path.join(ASSETS_DIR, "ui", "joystick_base.png"))
    
    # Knob 64x64
    j_knob = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(j_knob)
    d.ellipse([4, 4, 60, 60], fill=(184, 92, 56, 210), outline=(247, 240, 222, 230), width=3)
    d.ellipse([22, 22, 42, 42], fill=(217, 164, 65, 220))
    j_knob.save(os.path.join(ASSETS_DIR, "ui", "joystick_knob.png"))

def main():
    ensure_dirs()
    print("Generating Character sheets...")
    create_character_sheet("mekatilili").save(os.path.join(ASSETS_DIR, "characters", "mekatilili.png"))
    create_character_sheet("elder").save(os.path.join(ASSETS_DIR, "characters", "mzee_fondo.png"))
    create_character_sheet("wanje").save(os.path.join(ASSETS_DIR, "characters", "wanje.png"))
    create_character_sheet("nyevu").save(os.path.join(ASSETS_DIR, "characters", "villager_nyevu.png"))
    create_character_sheet("warrior").save(os.path.join(ASSETS_DIR, "characters", "warrior_charo.png"))
    create_character_sheet("colonial").save(os.path.join(ASSETS_DIR, "characters", "arthur_champion.png"))
    
    print("Generating Portraits...")
    create_portrait("mekatilili").save(os.path.join(ASSETS_DIR, "characters", "portraits", "mekatilili.png"))
    create_portrait("elder").save(os.path.join(ASSETS_DIR, "characters", "portraits", "mzee_fondo.png"))
    create_portrait("wanje").save(os.path.join(ASSETS_DIR, "characters", "portraits", "wanje.png"))
    create_portrait("nyevu").save(os.path.join(ASSETS_DIR, "characters", "portraits", "nyevu.png"))
    create_portrait("charo").save(os.path.join(ASSETS_DIR, "characters", "portraits", "charo.png"))
    create_portrait("champion").save(os.path.join(ASSETS_DIR, "characters", "portraits", "champion.png"))
    
    print("Generating Environment assets...")
    create_environment_assets()
    
    print("Generating Items and Icons...")
    create_items_and_icons()
    
    print("Generating UI assets...")
    create_ui_assets()
    
    print("All assets successfully generated!")

if __name__ == "__main__":
    main()
