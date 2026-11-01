#!/usr/bin/env python3
"""Read-only STL catalog and static viewer, using only the Python standard library."""
import hashlib
import json
import mimetypes
import os
from pathlib import Path
import stat
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import quote, unquote, urlsplit

MODEL_ROOT = Path(os.environ.get('MODEL_ROOT', '/models')).resolve()
WEB_ROOT = Path(__file__).parent / 'web'

def model_entries(root=MODEL_ROOT):
    entries = []
    for directory, directories, files in os.walk(root, followlinks=False):
        directories[:] = [d for d in directories if not d.startswith('.') and not (Path(directory) / d).is_symlink()]
        for name in files:
            path = Path(directory) / name
            if name.startswith('.') or path.suffix.lower() != '.stl' or path.is_symlink():
                continue
            try:
                info = path.stat()
            except FileNotFoundError:
                continue
            if not stat.S_ISREG(info.st_mode) or info.st_size == 0:
                continue
            relative = path.relative_to(root).as_posix()
            entries.append(dict(id=relative, name=name, folder=path.parent.relative_to(root).as_posix(),
                                size=info.st_size, modified=info.st_mtime,
                                version=f'{info.st_mtime_ns:x}-{info.st_size:x}',
                                url='/models/' + quote(relative, safe='/')))
    return sorted(entries, key=lambda e: (-e['modified'], e['id']))

def open_model(relative, root=MODEL_ROOT):
    """Resolve every component without following symlinks, including during races."""
    parts = relative.split('/')
    if any(not p or p.startswith('.') or '\\' in p or '\x00' in p for p in parts) or Path(parts[-1]).suffix.lower() != '.stl':
        raise FileNotFoundError(relative)
    descriptor = os.open(root, os.O_RDONLY | os.O_DIRECTORY)
    try:
        for part in parts[:-1]:
            next_descriptor = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=descriptor)
            os.close(descriptor)
            descriptor = next_descriptor
        file_descriptor = os.open(parts[-1], os.O_RDONLY | os.O_NOFOLLOW, dir_fd=descriptor)
        if not stat.S_ISREG(os.fstat(file_descriptor).st_mode):
            os.close(file_descriptor)
            raise FileNotFoundError(relative)
        return os.fdopen(file_descriptor, 'rb')
    finally:
        os.close(descriptor)

class Handler(BaseHTTPRequestHandler):
    server_version = 'ModelGallery'

    def do_HEAD(self):
        self.do_GET()

    def send_headers(self, status, content_type, length, etag=None, cache='no-cache'):
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(length))
        self.send_header('Cache-Control', cache)
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('Referrer-Policy', 'no-referrer')
        self.send_header('Content-Security-Policy', "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data: blob:; connect-src 'self'; worker-src 'self' blob:; object-src 'none'; base-uri 'none'; frame-ancestors 'none'")
        if etag:
            self.send_header('ETag', etag)
        self.end_headers()

    def send_bytes(self, data, content_type, etag=None):
        if etag and self.headers.get('If-None-Match') == etag:
            self.send_headers(304, content_type, 0, etag)
            return
        self.send_headers(200, content_type, len(data), etag)
        if self.command != 'HEAD':
            self.wfile.write(data)

    def do_GET(self):
        path = unquote(urlsplit(self.path).path)
        try:
            if path == '/healthz':
                self.send_bytes(b'{"status":"ok"}', 'application/json')
            elif path == '/api/models':
                data = json.dumps(dict(models=model_entries()), ensure_ascii=False).encode()
                self.send_bytes(data, 'application/json; charset=utf-8', '"' + hashlib.sha256(data).hexdigest() + '"')
            elif path.startswith('/models/'):
                with open_model(path[len('/models/'):]) as source:
                    info = os.fstat(source.fileno())
                    etag = f'"{info.st_mtime_ns:x}-{info.st_size:x}"'
                    if self.headers.get('If-None-Match') == etag:
                        self.send_headers(304, 'model/stl', 0, etag)
                        return
                    self.send_headers(200, 'model/stl', info.st_size, etag)
                    if self.command != 'HEAD':
                        while block := source.read(256 * 1024):
                            self.wfile.write(block)
            else:
                relative = 'index.html' if path == '/' else path.lstrip('/')
                if any(p.startswith('.') or p == '..' for p in relative.split('/')):
                    raise FileNotFoundError(path)
                source = (WEB_ROOT / relative).resolve()
                if not source.is_relative_to(WEB_ROOT.resolve()) or not source.is_file():
                    raise FileNotFoundError(path)
                data = source.read_bytes()
                content_type = mimetypes.guess_type(source)[0] or 'application/octet-stream'
                self.send_bytes(data, content_type, '"' + hashlib.sha256(data).hexdigest() + '"')
        except (FileNotFoundError, ValueError, OSError) as error:
            if isinstance(error, (BrokenPipeError, ConnectionResetError)):
                return
            self.send_error(404, 'Not found')

if __name__ == '__main__':
    ThreadingHTTPServer((os.environ.get('BIND_HOST', '0.0.0.0'), int(os.environ.get('PORT', '8080'))), Handler).serve_forever()
