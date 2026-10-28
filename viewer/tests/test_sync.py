"""Exercise atomic upload batches, retries, and non-propagation of deletions."""
import importlib.util
import json
import os
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('sync_models', Path(__file__).parents[1] / 'sync/sync_models.py')
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)

class SyncTests(unittest.TestCase):
    def test_atomic_upload_change_and_no_delete(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / 'exports'
            source.mkdir()
            file = source / 'part "one".stl'
            file.write_bytes(b'first mesh')
            (source / 'private.json').write_text('not public')
            (source / 'link.stl').symlink_to(file)
            config = dict(source=str(source), state_dir=str(root / 'state'), identity='/private/key-path',
                          infra_root=str(root / 'infra'), settle_seconds=0)
            with patch.object(sync.subprocess, 'run', return_value=SimpleNamespace(returncode=0, stderr='')) as transfer:
                sync.synchronize(config)
                self.assertEqual(transfer.call_count, 1)
                batch = transfer.call_args.kwargs['input']
                self.assertIn('put -p ', batch)
                self.assertIn('rename ', batch)
                self.assertIn('.part', batch)
                self.assertNotIn('private.json', batch)
                self.assertNotIn('link.stl', batch)
                self.assertNotIn('remove ', batch)
                sync.synchronize(config)
                self.assertEqual(transfer.call_count, 1)
                file.write_bytes(b'changed mesh')
                sync.synchronize(config)
                self.assertEqual(transfer.call_count, 2)
                file.unlink()
                sync.synchronize(config)
                self.assertEqual(transfer.call_count, 2)
                self.assertIn(file.name, json.loads((root / 'state/published.json').read_text()))

    def test_failed_upload_does_not_mark_published(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / 'exports'
            source.mkdir()
            (source / 'part.stl').write_bytes(b'mesh')
            config = dict(source=str(source), state_dir=str(root / 'state'), identity='/private/key-path',
                          infra_root=str(root / 'infra'), settle_seconds=0)
            with patch.object(sync.subprocess, 'run', return_value=SimpleNamespace(returncode=1, stderr='unreachable')):
                with self.assertRaises(RuntimeError):
                    sync.synchronize(config)
            self.assertFalse((root / 'state/published.json').exists())

if __name__ == '__main__':
    unittest.main()
