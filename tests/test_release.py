"""Offline artifact/fixture checks. These do not replace FG runtime acceptance."""
from pathlib import Path
import hashlib
import importlib.util
import io
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


builder = load('cointransfer_builder', ROOT / 'build_release.py')
fixture = load('cointransfer_fixture', ROOT / 'tests' / 'build_fixture.py')


class ReleaseChecks(unittest.TestCase):
    def test_standalone_payload_license_version_and_no_tests(self):
        with zipfile.ZipFile(io.BytesIO(builder.archive_bytes())) as archive:
            self.assertIsNone(archive.testzip())
            self.assertEqual(set(archive.namelist()), {'extension.xml', 'LICENSE.txt', *builder.FILES})
            self.assertEqual(archive.read('LICENSE.txt'), (ROOT / 'LICENSE').read_bytes().replace(b'\r\n', b'\n'))
            self.assertTrue(all(Path(n).suffix.lower() in builder.FORGE_EXTENSIONS for n in archive.namelist()))
            manifest = ET.fromstring(archive.read('extension.xml'))
            self.assertEqual(manifest.findtext('properties/version'), '0.1.4')
            self.assertNotIn(b'CoinTransferTests', archive.read('extension.xml'))
            for node in manifest.findall('base/*'):
                path = node.get('file') or node.get('source')
                if path:
                    self.assertIn(path, archive.namelist())
            for name in builder.FILES:
                self.assertEqual(archive.read(name), (ROOT / 'extension' / name).read_bytes().replace(b'\r\n', b'\n'))

    def test_rebuild_ignores_source_mtime_and_windows_line_endings(self):
        before = hashlib.sha256(builder.archive_bytes()).hexdigest()
        with tempfile.TemporaryDirectory(prefix='cointransfer-build-') as tmp:
            root = Path(tmp)
            shutil.copytree(ROOT / 'extension', root / 'extension')
            shutil.copy2(ROOT / 'LICENSE', root / 'LICENSE')
            for path in [*root.rglob('*.lua'), *root.rglob('*.xml'), root / 'LICENSE']:
                data = path.read_bytes().replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')
                path.write_bytes(data)
                os.utime(path, (1735689600, 1735689600))
            self.assertEqual(before, hashlib.sha256(builder.archive_bytes(root)).hexdigest())

    def test_version_drift_fails_build(self):
        with tempfile.TemporaryDirectory(prefix='cointransfer-version-') as tmp:
            root = Path(tmp)
            shutil.copytree(ROOT / 'extension', root / 'extension')
            shutil.copy2(ROOT / 'LICENSE', root / 'LICENSE')
            path = root / 'extension' / 'extension.xml'
            path.write_text(path.read_text(encoding='utf-8').replace('<version>0.1.4</version>', '<version>99.0.0</version>'), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'versions differ'):
                builder.archive_bytes(root)

    def test_missing_license_fails_build(self):
        with tempfile.TemporaryDirectory(prefix='cointransfer-license-') as tmp:
            root = Path(tmp)
            shutil.copytree(ROOT / 'extension', root / 'extension')
            with self.assertRaises(FileNotFoundError):
                builder.archive_bytes(root)

    def test_forge_disallowed_payload_extension_is_rejected(self):
        original = builder.FILES
        try:
            with tempfile.TemporaryDirectory(prefix='cointransfer-forge-') as tmp:
                root = Path(tmp)
                shutil.copytree(ROOT / 'extension', root / 'extension')
                shutil.copy2(ROOT / 'LICENSE', root / 'LICENSE')
                (root / 'extension' / 'unexpected.bin').write_bytes(b'not permitted')
                builder.FILES = (*original, 'unexpected.bin')
                with self.assertRaisesRegex(ValueError, 'not permitted in Forge'):
                    builder.archive_bytes(root)
        finally:
            builder.FILES = original

    def test_builder_refuses_to_overwrite_published_artifact(self):
        published = ROOT / 'release' / 'CoinTransfer.ext'
        before = published.read_bytes()
        result = subprocess.run([sys.executable, str(ROOT / 'build_release.py'), '--output', str(published)], capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('published artifacts', result.stderr)
        self.assertEqual(published.read_bytes(), before)

    def test_synthetic_membership_outsider_and_tests_off(self):
        root = fixture.campaign_tree()
        self.assertIsNone(root.find('partysheet/list'))
        self.assertEqual([n.text for n in root.findall('partysheet/partyinformation/*/link/recordname')], ['charsheet.id-00001', 'charsheet.id-00002'])
        self.assertEqual(len(root.findall('charsheet/*')), 3)
        self.assertEqual(root.findtext('charsheet/id-00003/name'), 'Coin Transfer Outsider')
        self.assertEqual(root.findtext('cointransfertest/fixture'), fixture.MARKER)
        self.assertEqual(root.findtext('cointransfertest/enabled'), '0')
        self.assertEqual(fixture.campaign_tree(True).findtext('cointransfertest/enabled'), '1')
        self.assertFalse(root.findall('.//holder') or root.findall('.//token') or root.findall('.//modules'))
        for char in root.findall('charsheet/*'):
            self.assertEqual(char.findtext('abilities/strength/score'), '10')
            self.assertEqual(len(char.findall('coins/*')), 5)
            self.assertEqual(len(char.findall('inventorylist/*')), 3)

    def test_fixture_roundtrip_and_refuses_overwrite(self):
        with tempfile.TemporaryDirectory(prefix='cointransfer-fixture-') as tmp:
            output = Path(tmp) / 'fresh'
            fixture.write_fixture(output, True)
            self.assertEqual(ET.parse(output / 'db.xml').findtext('cointransfertest/fixture'), fixture.MARKER)
            self.assertEqual(ET.parse(output / 'campaign.xml').findtext('ruleset'), '5E')
            with self.assertRaises(FileExistsError):
                fixture.write_fixture(output)


if __name__ == '__main__':
    unittest.main()
