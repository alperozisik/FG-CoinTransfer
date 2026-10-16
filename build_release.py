from pathlib import Path
import zipfile
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parent
source = root / 'extension'
release = root / 'release'
release.mkdir(exist_ok=True)
xml = (source / 'extension.xml').read_text(encoding='utf-8')
xml = '\n'.join(line for line in xml.splitlines() if 'CoinTransferTests' not in line) + '\n'
ET.fromstring(xml)
files = ['scripts/coin_transfer_service.lua', 'scripts/coin_transfer_window.lua', 'scripts/coin_transfer_party_totals.lua', 'windows/coin_transfer.xml']
ET.parse(source / files[-1])
with zipfile.ZipFile(release / 'CoinTransfer.ext', 'w', zipfile.ZIP_DEFLATED) as package:
    package.writestr('extension.xml', xml)
    for filename in files:
        package.write(source / filename, filename)
(release / 'extension.xml').write_text(xml, encoding='utf-8')
print(release / 'CoinTransfer.ext')
