from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import pwd
import grp

PORT = 8080

def check_writable(path):
    probe = os.path.join(path, "write-probe")
    try:
        with open(probe, "w") as f:
            f.write("ok")
        os.remove(probe)
        return True
    except Exception as error:
        return f"{type(error).__name__}: {error}"

class Handler(BaseHTTPRequestHandler):
    def _send_json(self, payload, status=200):
        body = json.dumps(payload, indent=2).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/":
            uid = os.getuid()
            gid = os.getgid()

            payload = {
                "status": "running",
                "uid": uid,
                "gid": gid,
                "user": pwd.getpwuid(uid).pw_name,
                "group": grp.getgrgid(gid).gr_name,
                "writable_paths": {
                    "/tmp": check_writable("/tmp"),
                    "/app": check_writable("/app"),
                    "/bin": check_writable("/bin"),
                    "/etc": check_writable("/etc")
                }
            }
            self._send_json(payload)

        elif self.path == "/read-shadow":
            try:
                with open("/etc/shadow", "r") as f:
                    data = f.read(200)
                self._send_json({"shadow_read": True, "data": data})
            except Exception as error:
                self._send_json({
                    "shadow_read": False,
                    "message": "permission denied or blocked by security policy",
                    "error": str(error)
                }, status=403)

        elif self.path == "/write-proc-sys":
            try:
                with open("/proc/sys/kernel/hostname", "w") as f:
                    f.write("blocked-test")
                self._send_json({"proc_sys_write": True})
            except Exception as error:
                self._send_json({
                    "proc_sys_write": False,
                    "message": "write blocked by read-only filesystem or security policy",
                    "error": str(error)
                }, status=403)

        else:
            self._send_json({"error": "not found"}, status=404)

    def log_message(self, format, *args):
        print("%s - - %s" % (self.client_address[0], format % args))

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Starting hardened Python HTTP server on port {PORT}")
    server.serve_forever()
