#!/usr/bin/env python3
"""Render TaskFlow's vector logo. Requires ffmpeg with librsvg support."""
import json
import struct
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MARK = ROOT / 'assets/branding/taskflow-mark.svg'


def render(path, size, *, tile=False, maskable=False):
    svg = MARK.read_text()
    if tile:
        # Keep the entire mark within the maskable icon's central safe circle.
        scale = 0.64 if maskable else 0.76
        offset = 256 * (1 - scale) / 2
        body = svg[svg.index('>') + 1:svg.rindex('</svg>')]
        svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">'
               f'<path fill="#ffffff" d="M0 0h256v256H0z"/>'
               f'<g transform="translate({offset} {offset}) scale({scale})">{body}</g></svg>')
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        source = Path(tmp) / 'icon.svg'
        source.write_text(svg)
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-width', str(size * 4), '-height', str(size * 4), '-i', str(source),
                        '-vf', f'scale={size}:{size}:flags=lanczos',
                        '-pix_fmt', 'rgb24' if tile else 'rgba', '-frames:v', '1', str(path)], check=True)


if __name__ == '__main__':
    (ROOT / 'web/favicon.svg').write_text(MARK.read_text())
    for size in (16, 32, 48):
        render(ROOT / f'web/icons/favicon-{size}.png', size)
    frames = [(ROOT / f'web/icons/favicon-{s}.png').read_bytes() for s in (16, 32, 48)]
    offset = 6 + 16 * len(frames)
    ico = struct.pack('<HHH', 0, 1, len(frames))
    for size, data in zip((16, 32, 48), frames):
        ico += struct.pack('<BBBBHHII', size, size, 0, 0, 1, 32, len(data), offset)
        offset += len(data)
    (ROOT / 'web/favicon.ico').write_bytes(ico + b''.join(frames))
    render(ROOT / 'web/apple-touch-icon.png', 180, tile=True)
    for size in (192, 512):
        render(ROOT / f'web/icons/Icon-{size}.png', size, tile=True)
        render(ROOT / f'web/icons/Icon-maskable-{size}.png', size, tile=True, maskable=True)
    for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
        render(ROOT / f'android/app/src/main/res/mipmap-{density}/ic_launcher.png', size, tile=True)
    catalog = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for entry in json.loads((catalog / 'Contents.json').read_text())['images']:
        size = round(float(entry['size'].split('x')[0]) * float(entry['scale'][:-1]))
        render(catalog / entry['filename'], size, tile=True)
    print('Generated browser, install, Android, and iOS icons.')
