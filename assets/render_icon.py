"""Rasterize this project's simple original SVG primitives; optional Pillow tool."""
from pathlib import Path
import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent


def render(size=512):
    scale = size * 2 / 512
    image = Image.new('RGBA', (size * 2, size * 2))
    draw = ImageDraw.Draw(image)
    for element in ET.parse(ROOT / 'coin-transfer-icon.svg').getroot():
        tag = element.tag.rsplit('}', 1)[-1]
        a = element.attrib
        n = lambda key: float(a[key]) * scale
        if tag == 'rect':
            draw.rounded_rectangle((n('x'), n('y'), n('x') + n('width'), n('y') + n('height')), n('rx'), fill=a['fill'])
        elif tag == 'circle':
            draw.ellipse((n('cx') - n('r'), n('cy') - n('r'), n('cx') + n('r'), n('cy') + n('r')), fill=a['fill'])
        elif tag == 'polygon':
            points = [tuple(float(v) * scale for v in p.split(',')) for p in a['points'].split()]
            draw.polygon(points, fill=a['fill'])
        elif tag == 'line':
            points = [(n('x1'), n('y1')), (n('x2'), n('y2'))]
            width = round(n('stroke-width'))
            draw.line(points, fill=a['stroke'], width=width)
            for x, y in points:
                draw.ellipse((x-width/2, y-width/2, x+width/2, y+width/2), fill=a['stroke'])
        else:
            raise ValueError('Unsupported SVG primitive: ' + tag)
    return image.resize((size, size), Image.Resampling.LANCZOS)


if __name__ == '__main__':
    render().save(ROOT / 'coin-transfer-icon.png', optimize=True)
    render(96).save(ROOT / 'coin-transfer-icon-96.png', optimize=True)
