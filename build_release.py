"""Build a reproducible candidate, never overwrite a published release artifact."""
from pathlib import Path
import argparse
import hashlib
import io
import re
import zipfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent
FILES = (
    'scripts/coin_transfer_service.lua',
    'scripts/coin_transfer_window.lua',
    'scripts/coin_transfer_party_totals.lua',
    'windows/coin_transfer.xml',
)
FORGE_EXTENSIONS = {'.xml', '.jpg', '.jpeg', '.png', '.lua', '.txt', '.md', '.ttf', '.otf', '.fgf'}


def archive_bytes(root=ROOT):
    root = Path(root)
    source = root / 'extension'
    manifest = ET.fromstring((source / 'extension.xml').read_bytes())
    base = manifest.find('base')
    for script in list(base.findall('script')):
        if script.get('name') == 'CoinTransferTests':
            base.remove(script)
    version = manifest.findtext('properties/version')
    service = (source / FILES[0]).read_text(encoding='utf-8')
    runtime_version = re.search(r'local version = "([^"]+)";', service)
    if not runtime_version or runtime_version.group(1) != version:
        raise ValueError('Manifest and startup-message versions differ')
    license_data = (root / 'LICENSE').read_bytes().replace(b'\r\n', b'\n')
    if b'MIT License' not in license_data or b'Copyright (c)' not in license_data:
        raise ValueError('The full MIT license and copyright notice are required')
    ET.indent(manifest, space='  ')
    entries = {'extension.xml': ET.tostring(manifest, encoding='utf-8', xml_declaration=True) + b'\n'}
    for filename in FILES:
        data = (source / filename).read_bytes().replace(b'\r\n', b'\n')
        if filename.endswith('.xml'):
            ET.fromstring(data)
        entries[filename] = data
    entries['LICENSE.txt'] = license_data
    for filename in entries:
        if Path(filename).suffix.lower() not in FORGE_EXTENSIONS:
            raise ValueError('File extension is not permitted in Forge packages: ' + filename)
    out = io.BytesIO()
    with zipfile.ZipFile(out, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as package:
        for filename, data in entries.items():
            info = zipfile.ZipInfo(filename, date_time=(2020, 1, 1, 0, 0, 0))
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            package.writestr(info, data, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    return out.getvalue()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=ROOT / 'dist' / 'CoinTransfer.ext')
    args = parser.parse_args()
    output = args.output.resolve()
    if output.is_relative_to((ROOT / 'release').resolve()):
        parser.error('release/ contains published artifacts; build candidates into dist/')
    data = archive_bytes()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(data)
    print(output)
    print('SHA-256:', hashlib.sha256(data).hexdigest())


if __name__ == '__main__':
    main()
