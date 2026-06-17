#!/usr/bin/env python3

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import logging
import subprocess

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("webhook-listener")


class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != "/webhook/build":
            self.send_response(404)
            self.end_headers()
            return

        content_length = int(self.headers.get("Content-Length", 0))
        raw_body = self.rfile.read(content_length)

        try:
            payload = json.loads(raw_body.decode("utf-8") or "{}")
            logger.info("Received webhook payload: %s", payload)

            result = subprocess.run(
                [
                    "curl",
                    "-X",
                    "POST",
                    "http://localhost:8080/job/jenkins-container-pipeline/build"
                ],
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode != 0:
                raise RuntimeError(result.stderr or result.stdout)

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({
                "status": "success",
                "message": "Build trigger request sent"
            }).encode("utf-8"))

        except Exception as error:
            logger.exception("Webhook processing failed")
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({
                "status": "error",
                "message": str(error)
            }).encode("utf-8"))


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8081), WebhookHandler)
    logger.info("Webhook listener started on http://0.0.0.0:8081/webhook/build")
    server.serve_forever()
