"""Check public catalog boundaries and original-date ordering."""
import importlib.util
import os
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('gallery', Path(__file__).parents[1] / 'server.py')
gallery = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gallery)

class CatalogTests(unittest.TestCase):
    def test_catalog_dates_hidden_files_and_links(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / 'day').mkdir()
            for name, timestamp in [('older.stl', 100), ('day/newer.STL', 200)]:
                (root / name).write_bytes(b'mesh')
                os.utime(root / name, (timestamp, timestamp))
            (root / 'secret.txt').write_text('private')
            (root / '.partial.stl').write_bytes(b'partial')
            (root / 'link.stl').symlink_to(root / 'secret.txt')
            (root / 'linked-dir').symlink_to(root / 'day', target_is_directory=True)
            entries = gallery.model_entries(root)
            self.assertEqual([e['id'] for e in entries], ['day/newer.STL', 'older.stl'])
            self.assertEqual(entries[0]['modified'], 200)

    def test_public_reader_rejects_traversal_and_symlinks(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / 'part.stl').write_bytes(b'mesh')
            (root / 'linked.stl').symlink_to(root / 'part.stl')
            (root / 'linked-dir').symlink_to(root, target_is_directory=True)
            with gallery.open_model('part.stl', root) as stream:
                self.assertEqual(stream.read(), b'mesh')
            for name in ['../part.stl', '.hidden.stl', 'linked.stl', 'linked-dir/part.stl', 'part.txt', '/part.stl', 'a//part.stl']:
                with self.subTest(name=name), self.assertRaises(OSError):
                    gallery.open_model(name, root)

if __name__ == '__main__':
    unittest.main()
