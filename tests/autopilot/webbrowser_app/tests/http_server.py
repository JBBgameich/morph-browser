# -*- coding: utf-8 -*-
#
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

import BaseHTTPServer
import threading
import time


class HTTPRequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):

    """
    A custom HTTP request handler that serves GET resources.
    """

    def make_html(self, title, body):
        return "<html><title>%s</title><body>%s</body></html>" % (title, body)

    def send_html(self, html):
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(html)

    def do_GET(self):
        if self.path == "/loremipsum":
            self.send_response(200)
            title = "Lorem Ipsum"
            body = "<p>Lorem ipsum dolor sit amet.</p>"
            html = self.make_html(title, body)
            self.send_html(html)
        elif self.path == "/aleaiactaest":
            self.send_response(200)
            title = "Alea Iacta Est"
            body = "<p>De vita Caesarum libri VIII</p>"
            html = self.make_html(title, body)
            self.send_html(html)
        elif self.path.startswith("/wait/"):
            delay = int(self.path[6:])
            self.send_response(200)
            title = "waiting %d seconds" % delay
            body = "<p>this page took %d seconds to load</p>" % delay
            html = self.make_html(title, body)
            time.sleep(delay)
            self.send_html(html)
        elif self.path == "/blanktargetlink":
            # craft a page that accepts clicks anywhere inside its window
            # and that requests opening another page in a new tab
            self.send_response(200)
            port = self.server.server_address[1]
            url = 'http://localhost:%s/aleaiactaest' % port
            html = '<html><body style="margin: 0">'
            html += '<a href="%s" target="_blank">' % url
            html += '<div style="height: 100%"></div></a>'
            html += '</body></html>'
            self.send_html(html)
        elif self.path == "/fulliframewithblanktargetlink":
            # iframe that takes up the whole page and that contains
            # the page above
            self.send_response(200)
            html = '<html><body style="margin: 0">'
            html += '<iframe height="100%" width="100%" '
            html += 'src="/blanktargetlink" />'
            html += '</body></html>'
            self.send_html(html)
        else:
            self.send_error(404)


class HTTPServerInAThread(threading.Thread):

    """
    A simple custom HTTP server run in a separate thread.
    """

    def __init__(self, port):
        super(HTTPServerInAThread, self).__init__()
        self.server = BaseHTTPServer.HTTPServer(("", port), HTTPRequestHandler)
        self.server.allow_reuse_address = True

    def run(self):
        self.server.serve_forever()

    def shutdown(self):
        self.server.shutdown()
        self.server.server_close()


__all__ = ["HTTPServerInAThread"]