#!/usr/bin/env python3
"""Generate the game's icon set as layered-vector-style PNGs (1024x1024).

Output: assets/icons/*.png + assets/icons/contact_sheet.png
Upload the individual PNGs as Decals on create.roblox.com, then paste the
asset ids into src/shared/GameData/IconAssets.lua (see README_ASSETS.md).
"""
import math
import os

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "icons")


def canvas():
    return Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))


def radial_bg(inner, outer):
    """Round badge background with a radial gradient + dark rim."""
    img = canvas()
    d = ImageDraw.Draw(img)
    cx = cy = SIZE // 2
    rmax = int(SIZE * 0.46)
    steps = 60
    for i in range(steps, 0, -1):
        t = i / steps
        r = int(rmax * t)
        col = tuple(int(inner[c] * (1 - t) + outer[c] * t) for c in range(3)) + (255,)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col)
    d.ellipse([cx - rmax, cy - rmax, cx + rmax, cy + rmax],
              outline=(15, 18, 30, 255), width=18)
    d.ellipse([cx - rmax + 22, cy - rmax + 22, cx + rmax - 22, cy + rmax - 22],
              outline=(255, 255, 255, 40), width=8)
    return img


def glow_layer(draw_fn, color, blur=40, alpha=180):
    img = canvas()
    d = ImageDraw.Draw(img)
    draw_fn(d, color + (alpha,))
    return img.filter(ImageFilter.GaussianBlur(blur))


def merge(*layers):
    out = canvas()
    for layer in layers:
        out = Image.alpha_composite(out, layer)
    return out


def poly_shaded(d, pts, base, light=1.25, dark=0.7):
    """Polygon with a fake top-light: split fill into light/dark halves."""
    d.polygon(pts, fill=tuple(min(255, int(c * dark)) for c in base) + (255,))
    cy = sum(p[1] for p in pts) / len(pts)
    top = [p for p in pts if p[1] <= cy]
    if len(top) >= 2:
        lighter = tuple(min(255, int(c * light)) for c in base) + (255,)
        d.polygon(top + [(sum(p[0] for p in pts) / len(pts), cy)], fill=lighter)


def gem(color, bg_in, bg_out):
    """Faceted hexagonal gem on a badge (spirit stone style)."""
    img = radial_bg(bg_in, bg_out)
    cx, cy, R = SIZE / 2, SIZE / 2, SIZE * 0.30
    hexpts = [(cx + R * math.cos(math.radians(60 * i - 90)),
               cy + R * math.sin(math.radians(60 * i - 90))) for i in range(6)]

    def shape(d, col):
        d.polygon(hexpts, fill=col)

    gl = glow_layer(shape, color, blur=50)
    body = canvas()
    d = ImageDraw.Draw(body)
    d.polygon(hexpts, fill=tuple(int(c * 0.55) for c in color) + (255,))
    # facets: triangles from centre to each edge, alternating brightness
    for i in range(6):
        a, b = hexpts[i], hexpts[(i + 1) % 6]
        f = 1.15 if i % 2 == 0 else 0.85
        col = tuple(min(255, int(c * f)) for c in color) + (255,)
        d.polygon([a, b, (cx, cy)], fill=col)
    # inner table
    inner = [(cx + (p[0] - cx) * 0.45, cy + (p[1] - cy) * 0.45) for p in hexpts]
    d.polygon(inner, fill=tuple(min(255, int(c * 1.35)) for c in color) + (255,))
    # sparkle
    d.line([(cx - 90, cy - 150), (cx - 30, cy - 90)], fill=(255, 255, 255, 230), width=22)
    d.line([(cx - 100, cy - 95), (cx - 45, cy - 148)], fill=(255, 255, 255, 160), width=14)
    d.polygon(hexpts, outline=(20, 24, 38, 255), width=14)
    return merge(img, gl, body)


def jade_disc(bg_in, bg_out):
    """Jade bi-disc with centre hole (immortal jade)."""
    img = radial_bg(bg_in, bg_out)
    cx = cy = SIZE / 2
    R, hole = SIZE * 0.30, SIZE * 0.10
    col = (52, 211, 153)

    def ring(d, c):
        d.ellipse([cx - R, cy - R, cx + R, cy + R], fill=c)

    gl = glow_layer(ring, col, blur=55)
    body = canvas()
    d = ImageDraw.Draw(body)
    for i in range(40, 0, -1):
        t = i / 40
        rr = R * (0.75 + 0.25 * t)
        shade = tuple(min(255, int(c * (1.25 - 0.5 * t))) for c in col) + (255,)
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=shade)
    # carved ring pattern
    for k in range(12):
        a = math.radians(k * 30)
        px, py = cx + math.cos(a) * R * 0.62, cy + math.sin(a) * R * 0.62
        d.ellipse([px - 26, py - 26, px + 26, py + 26],
                  outline=tuple(int(c * 0.55) for c in col) + (255,), width=10)
    d.ellipse([cx - hole, cy - hole, cx + hole, cy + hole], fill=(0, 0, 0, 0))
    d.ellipse([cx - hole, cy - hole, cx + hole, cy + hole],
              outline=tuple(int(c * 0.5) for c in col) + (255,), width=14)
    d.ellipse([cx - R, cy - R, cx + R, cy + R], outline=(16, 44, 36, 255), width=14)
    d.arc([cx - R * 0.82, cy - R * 0.82, cx + R * 0.82, cy + R * 0.82],
          200, 320, fill=(255, 255, 255, 150), width=20)
    out = merge(img, gl)
    out.paste(body, (0, 0), body)  # paste keeps the punched hole transparent
    return out


def taiji(bg_in, bg_out, a_col, b_col):
    """Taiji (yin-yang) emblem — game icon."""
    img = radial_bg(bg_in, bg_out)
    cx = cy = SIZE / 2
    R = SIZE * 0.30

    def disc(d, c):
        d.ellipse([cx - R, cy - R, cx + R, cy + R], fill=c)

    gl = glow_layer(disc, (245, 197, 66), blur=60)
    body = canvas()
    d = ImageDraw.Draw(body)
    d.ellipse([cx - R, cy - R, cx + R, cy + R], fill=b_col + (255,))
    d.pieslice([cx - R, cy - R, cx + R, cy + R], 90, 270, fill=a_col + (255,))
    d.ellipse([cx - R / 2, cy - R, cx + R / 2, cy], fill=a_col + (255,))
    d.ellipse([cx - R / 2, cy, cx + R / 2, cy + R], fill=b_col + (255,))
    r2 = R * 0.16
    d.ellipse([cx - r2, cy - R / 2 - r2, cx + r2, cy - R / 2 + r2], fill=b_col + (255,))
    d.ellipse([cx - r2, cy + R / 2 - r2, cx + r2, cy + R / 2 + r2], fill=a_col + (255,))
    d.ellipse([cx - R, cy - R, cx + R, cy + R], outline=(245, 197, 66, 255), width=20)
    return merge(img, gl, body)


def hourglass(bg_in, bg_out):
    img = radial_bg(bg_in, bg_out)
    cx, cy = SIZE / 2, SIZE / 2
    w, h = SIZE * 0.22, SIZE * 0.30
    sand = (250, 204, 21)
    frame = (120, 85, 40)

    def shape(d, c):
        d.polygon([(cx - w, cy - h), (cx + w, cy - h), (cx, cy)], fill=c)
        d.polygon([(cx - w, cy + h), (cx + w, cy + h), (cx, cy)], fill=c)

    gl = glow_layer(shape, sand, blur=45)
    body = canvas()
    d = ImageDraw.Draw(body)
    glass = (190, 225, 255, 120)
    d.polygon([(cx - w, cy - h), (cx + w, cy - h), (cx, cy)], fill=glass)
    d.polygon([(cx - w, cy + h), (cx + w, cy + h), (cx, cy)], fill=glass)
    poly_shaded(d, [(cx - w * 0.62, cy - h * 0.62), (cx + w * 0.62, cy - h * 0.62), (cx, cy)], sand)
    d.polygon([(cx - w * 0.85, cy + h), (cx + w * 0.85, cy + h),
               (cx + w * 0.5, cy + h * 0.55), (cx - w * 0.5, cy + h * 0.55)], fill=sand + (255,))
    d.line([(cx, cy), (cx, cy + h * 0.5)], fill=sand + (255,), width=16)
    for yy in (cy - h, cy + h):
        d.rounded_rectangle([cx - w - 40, yy - 26, cx + w + 40, yy + 26], 22, fill=frame + (255,))
    d.line([(cx - w, cy - h), (cx, cy), (cx - w, cy + h)], fill=(255, 255, 255, 170), width=10)
    return merge(img, gl, body)


def shield(bg_in, bg_out, main, trim):
    img = radial_bg(bg_in, bg_out)
    cx, cy = SIZE / 2, SIZE / 2 - 20
    w, h = SIZE * 0.26, SIZE * 0.34
    pts = [(cx - w, cy - h * 0.7), (cx + w, cy - h * 0.7), (cx + w, cy + h * 0.1),
           (cx, cy + h), (cx - w, cy + h * 0.1)]

    def shape(d, c):
        d.polygon(pts, fill=c)

    gl = glow_layer(shape, main, blur=45)
    body = canvas()
    d = ImageDraw.Draw(body)
    poly_shaded(d, pts, main)
    d.polygon(pts, outline=trim + (255,), width=20)
    # lightning bolt
    bolt = [(cx + 10, cy - h * 0.55), (cx - 60, cy + 10), (cx - 5, cy + 10),
            (cx - 30, cy + h * 0.7), (cx + 70, cy - 30), (cx + 10, cy - 30)]
    d.polygon(bolt, fill=(250, 204, 21, 255))
    return merge(img, gl, body)


def clover_coin(bg_in, bg_out):
    img = radial_bg(bg_in, bg_out)
    cx, cy = SIZE / 2, SIZE / 2
    R = SIZE * 0.30
    gold = (245, 197, 66)
    green = (52, 211, 153)

    def disc(d, c):
        d.ellipse([cx - R, cy - R, cx + R, cy + R], fill=c)

    gl = glow_layer(disc, gold, blur=50)
    body = canvas()
    d = ImageDraw.Draw(body)
    for i in range(30, 0, -1):
        t = i / 30
        rr = R * (0.8 + 0.2 * t)
        shade = tuple(min(255, int(c * (1.2 - 0.45 * t))) for c in gold) + (255,)
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=shade)
    d.ellipse([cx - R, cy - R, cx + R, cy + R], outline=(90, 62, 18, 255), width=16)
    d.ellipse([cx - R * 0.8, cy - R * 0.8, cx + R * 0.8, cy + R * 0.8],
              outline=(255, 245, 200, 160), width=10)
    leaf = R * 0.26
    for ang in (45, 135, 225, 315):
        a = math.radians(ang)
        px, py = cx + math.cos(a) * leaf * 1.1, cy + math.sin(a) * leaf * 1.1
        d.ellipse([px - leaf, py - leaf, px + leaf, py + leaf], fill=green + (255,))
    d.line([(cx, cy), (cx + 30, cy + R * 0.55)], fill=tuple(int(c * 0.6) for c in green) + (255,), width=18)
    return merge(img, gl, body)


def island_emblem(bg_in, bg_out, top, rock):
    """Floating island silhouette (world emblem)."""
    img = radial_bg(bg_in, bg_out)
    cx, cy = SIZE / 2, SIZE / 2 - 40
    w = SIZE * 0.30

    def shape(d, c):
        d.polygon([(cx - w, cy), (cx + w, cy), (cx, cy + w * 1.2)], fill=c)

    gl = glow_layer(shape, top, blur=45)
    body = canvas()
    d = ImageDraw.Draw(body)
    # tapered rock body
    layers = [(1.0, 0.0), (0.85, 0.25), (0.62, 0.5), (0.38, 0.75), (0.16, 1.0)]
    for i, (lw, ly) in enumerate(layers):
        yy = cy + ly * w * 1.05
        hh = w * 0.28
        shade = tuple(min(255, int(c * (1.0 - 0.12 * i))) for c in rock) + (255,)
        d.polygon([(cx - w * lw, yy), (cx + w * lw, yy),
                   (cx + w * lw * 0.78, yy + hh), (cx - w * lw * 0.78, yy + hh)], fill=shade)
    # grass top
    d.rounded_rectangle([cx - w, cy - 50, cx + w, cy + 14], 26, fill=top + (255,))
    d.rounded_rectangle([cx - w, cy - 50, cx + w, cy - 14], 26,
                        fill=tuple(min(255, int(c * 1.2)) for c in top) + (255,))
    # floating rocks
    for dx, dy, rr in ((-w * 1.25, w * 0.5, 46), (w * 1.3, w * 0.35, 36), (w * 1.05, w * 0.95, 26)):
        d.ellipse([cx + dx - rr, cy + dy - rr, cx + dx + rr, cy + dy + rr], fill=rock + (255,))
    return merge(img, gl, body)


def vortex(bg_in, bg_out, c1, c2):
    """Chaos vortex emblem (World 4)."""
    img = radial_bg(bg_in, bg_out)
    cx = cy = SIZE / 2
    body = canvas()
    d = ImageDraw.Draw(body)
    for arm in range(3):
        base = math.radians(arm * 120)
        col = c1 if arm % 2 == 0 else c2
        pts = []
        for t in range(40):
            tt = t / 39
            a = base + tt * 3.6
            r = SIZE * 0.05 + tt * SIZE * 0.27
            pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r))
        for t in range(39, -1, -1):
            tt = t / 39
            a = base + tt * 3.6 + 0.35 * (1 - tt)
            r = SIZE * 0.05 + tt * SIZE * 0.27
            pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r))
        d.polygon(pts, fill=col + (255,))
    d.ellipse([cx - 60, cy - 60, cx + 60, cy + 60], fill=(10, 6, 18, 255))
    d.ellipse([cx - 26, cy - 26, cx + 26, cy + 26], fill=(255, 255, 255, 230))
    gl = body.filter(ImageFilter.GaussianBlur(36))
    return merge(img, gl, body)


ICONS = {
    "game_icon":      lambda: taiji((38, 33, 73), (8, 9, 18), (245, 197, 66), (20, 22, 38)),
    "spirit_stone":   lambda: gem((103, 232, 249), (30, 47, 75), (7, 11, 22)),
    "immortal_jade":  lambda: jade_disc((24, 56, 48), (6, 14, 12)),
    "karma_scale":    lambda: taiji((45, 30, 60), (10, 7, 16), (168, 85, 247), (30, 20, 45)),
    "exp_orb":        lambda: gem((168, 85, 247), (44, 28, 70), (10, 7, 18)),
    "fortune_charm":  lambda: clover_coin((52, 44, 26), (12, 10, 6)),
    "stone_magnet":   lambda: gem((245, 197, 66), (58, 46, 20), (14, 11, 5)),
    "time_talisman":  lambda: hourglass((40, 36, 56), (10, 9, 16)),
    "tribulation_ward": lambda: shield((38, 33, 73), (8, 9, 18), (108, 126, 248), (245, 197, 66)),
    "world1_mortal":  lambda: island_emblem((28, 52, 38), (7, 13, 10), (110, 214, 130), (124, 96, 66)),
    "world2_sky":     lambda: island_emblem((30, 52, 64), (7, 12, 16), (150, 220, 255), (170, 200, 225)),
    "world3_sage":    lambda: island_emblem((44, 30, 64), (11, 7, 16), (190, 140, 255), (90, 80, 110)),
    "world4_chaos":   lambda: vortex((40, 10, 24), (10, 3, 7), (244, 63, 94), (168, 85, 247)),
}


def main():
    os.makedirs(OUT, exist_ok=True)
    names = []
    for name, fn in ICONS.items():
        img = fn()
        img.save(os.path.join(OUT, f"{name}.png"))
        names.append(name)
        print("✓", name)

    # contact sheet 4 columns
    cols, cell = 4, 256
    rows = (len(names) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * cell, rows * (cell + 28)), (11, 14, 25, 255))
    from PIL import ImageDraw as ID
    d = ID.Draw(sheet)
    for i, name in enumerate(names):
        img = Image.open(os.path.join(OUT, f"{name}.png")).resize((cell - 16, cell - 16))
        x, y = (i % cols) * cell, (i // cols) * (cell + 28)
        sheet.paste(img, (x + 8, y + 8), img)
        d.text((x + cell // 2, y + cell + 2), name, fill=(230, 232, 255, 255), anchor="ma")
    sheet.save(os.path.join(OUT, "contact_sheet.png"))
    print("✓ contact_sheet")


if __name__ == "__main__":
    main()
