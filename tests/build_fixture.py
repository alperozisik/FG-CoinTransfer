"""Create an invented, isolated FG test campaign without reading any campaign."""
from pathlib import Path
import argparse
import xml.etree.ElementTree as ET

MARKER = 'cointransfer-synthetic-v1'
CURRENCIES = [('PP', 10), ('GP', 1), ('EP', 0.5), ('SP', 0.1), ('CP', 0.01)]


def field(parent, name, value, kind='string'):
    parts = name.split('.')
    for part in parts[:-1]:
        child = parent.find(part)
        parent = child if child is not None else ET.SubElement(parent, part)
    ET.SubElement(parent, parts[-1], {'type': kind}).text = str(value)


def campaign_tree(enable_tests=False):
    root = ET.Element('root', {'version': '5.1', 'dataversion': '20260124'})
    currencies = ET.SubElement(root, 'currencies')
    ET.SubElement(currencies, 'public')
    for i, (code, value) in enumerate(CURRENCIES, 1):
        n = ET.SubElement(currencies, f'id-{i:05d}')
        field(n, 'name', code)
        field(n, 'value', value, 'number')
        field(n, 'weight', 0.02, 'number')
    options = ET.SubElement(root, 'options')
    for key, value in [('inventoryCoinsMNM', 'no'), ('PSIN', 'on'), ('SOUND', 'off')]:
        field(options, key, value)
    chars = ET.SubElement(root, 'charsheet')
    for i, name in enumerate(['Coin Transfer Test 1', 'Coin Transfer Test 2', 'Coin Transfer Outsider'], 1):
        char = ET.SubElement(chars, f'id-{i:05d}')
        field(char, 'name', name)
        field(char, 'level', 1, 'number')
        for ability in ['strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma']:
            field(char, f'abilities.{ability}.score', 10, 'number')
        coins = ET.SubElement(char, 'coins')
        for j, (code, _) in enumerate(CURRENCIES, 1):
            coin = ET.SubElement(coins, f'id-{j:05d}')
            field(coin, 'name', code)
            field(coin, 'amount', {'GP': 100, 'SP': 20, 'CP': 5, 'PP': 2}.get(code, 0), 'number')
        inv = ET.SubElement(char, 'inventorylist')
        for j, (container, weight, capacity) in enumerate([('Bag of Holding', 15, 500), ('Backpack', 5, 30), ('Pouch', 1, 6)], 1):
            item = ET.SubElement(inv, f'id-{j:05d}')
            for key, value in [('name', container), ('type', 'Adventuring Gear'), ('subtype', 'Container')]:
                field(item, key, value)
            for key, value in [('weight', weight), ('capacityweight', capacity), ('count', 1), ('carried', 1), ('isidentified', 1)]:
                field(item, key, value, 'number')
        ET.SubElement(char, 'cointransfer')
    party = ET.SubElement(root, 'partysheet')
    ET.SubElement(party, 'public')
    members = ET.SubElement(party, 'partyinformation')
    for i in [1, 2]:
        entry = ET.SubElement(members, f'id-{i:05d}')
        field(entry, 'name', f'Coin Transfer Test {i}')
        ref = ET.SubElement(entry, 'link', {'type': 'windowreference'})
        ET.SubElement(ref, 'class').text = 'charsheet'
        ET.SubElement(ref, 'recordname').text = f'charsheet.id-{i:05d}'
    shared = ET.SubElement(party, 'treasureparcelcoinlist')
    for i, (code, _) in enumerate(CURRENCIES, 1):
        coin = ET.SubElement(shared, f'id-{i:05d}')
        field(coin, 'description', code)
        field(coin, 'amount', {'GP': 300, 'SP': 80, 'CP': 50, 'PP': 5}.get(code, 0), 'number')
    ET.SubElement(root, 'item')
    tests = ET.SubElement(root, 'cointransfertest')
    field(tests, 'fixture', MARKER)
    field(tests, 'enabled', int(enable_tests), 'number')
    return root


def write_fixture(output, enable_tests=False):
    output = Path(output)
    # Never overwrite an existing campaign or a partially used fixture.
    output.mkdir(parents=True, exist_ok=False)
    tree = campaign_tree(enable_tests)
    ET.indent(tree, space='  ')
    ET.ElementTree(tree).write(output / 'db.xml', encoding='utf-8', xml_declaration=True)
    campaign = ET.Element('root', {'version': '5.1'})
    for key, value in [('ruleset', '5E'), ('server', 'personal'), ('port', '1803')]:
        ET.SubElement(campaign, key).text = value
    ET.ElementTree(campaign).write(output / 'campaign.xml', encoding='utf-8', xml_declaration=True)
    extensions = ET.Element('extensionstate', {'version': '5.1'})
    ET.SubElement(extensions, 'extension', {'name': 'CoinTransfer'})
    ET.ElementTree(extensions).write(output / 'extensionstate.xml', encoding='utf-8', xml_declaration=True)
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[1] / 'dist' / 'sandbox')
    parser.add_argument('--enable-tests', action='store_true')
    args = parser.parse_args()
    print(write_fixture(args.output, args.enable_tests))


if __name__ == '__main__':
    main()
