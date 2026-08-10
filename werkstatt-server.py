"""Kleiner lokaler Webserver fuer die Werkstatt-Auftragsverwaltung.

Unterschied zu 'python -m http.server': Dieser Server verbietet dem Browser
ausdruecklich das Zwischenspeichern. Damit wird nach dem Austausch einer Datei
immer die neue Fassung geladen, ohne Strg+F5.
"""
import http.server
import socketserver
import sys
import os

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8765


class OhneZwischenspeicher(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

    def log_message(self, format, *args):
        # favicon-Rauschen unterdruecken, alles andere protokollieren
        if 'favicon' in format % args:
            return
        super().log_message(format, *args)


os.chdir(os.path.dirname(os.path.abspath(__file__)))
socketserver.TCPServer.allow_reuse_address = True

try:
    with socketserver.TCPServer(('127.0.0.1', PORT), OhneZwischenspeicher) as srv:
        print('Server laeuft auf http://localhost:%d/  (Zwischenspeicher aus)' % PORT)
        print('Ordner: %s' % os.getcwd())
        print('Beenden mit Strg+C.')
        srv.serve_forever()
except OSError as e:
    print('Start fehlgeschlagen: %s' % e)
    print('Laeuft bereits ein Starter-Fenster auf Port %d? Dann dieses zuerst schliessen.' % PORT)
    input('Mit Eingabetaste beenden ...')
except KeyboardInterrupt:
    print('\nBeendet.')
