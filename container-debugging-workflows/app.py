import time
import logging
from http.server import HTTPServer, BaseHTTPRequestHandler

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

class SimpleHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        logger.info(f"Received GET request for {self.path}")

        if self.path == '/':
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'Debug Application Running')

        elif self.path == '/error':
            logger.error("Intentional error endpoint accessed")
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b'Internal Server Error')

        elif self.path == '/slow':
            logger.warning("Slow endpoint accessed")
            time.sleep(5)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'Slow response completed')

        else:
            logger.warning(f"404 path not found: {self.path}")
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not Found')

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8080), SimpleHandler)
    logger.info("Starting server on port 8080")
    server.serve_forever()
