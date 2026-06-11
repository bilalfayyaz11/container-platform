from flask import Flask, request, jsonify, session
import os
import sqlite3
from datetime import datetime
import redis

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "change-this-secret-key")

DATABASE = os.environ.get("DATABASE_PATH", "/app/data/visitors.db")
REDIS_HOST = os.environ.get("REDIS_HOST", "redis")
REDIS_PORT = int(os.environ.get("REDIS_PORT", "6379"))


def get_redis_client():
    try:
        client = redis.Redis(
            host=REDIS_HOST,
            port=REDIS_PORT,
            db=0,
            decode_responses=True,
            socket_connect_timeout=2,
        )
        client.ping()
        return client
    except Exception:
        return None


def init_db():
    os.makedirs(os.path.dirname(DATABASE), exist_ok=True)
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS visitors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ip_address TEXT,
            visit_time TIMESTAMP,
            user_agent TEXT,
            session_id TEXT
        )
        """
    )
    conn.commit()
    conn.close()


def log_visitor(ip_address, user_agent, session_id):
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute(
        """
        INSERT INTO visitors (ip_address, visit_time, user_agent, session_id)
        VALUES (?, ?, ?, ?)
        """,
        (ip_address, datetime.utcnow().isoformat(), user_agent, session_id),
    )
    conn.commit()
    conn.close()


def get_visitor_count():
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM visitors")
    count = cursor.fetchone()[0]
    conn.close()
    return count


@app.route("/")
def home():
    if "session_id" not in session:
        session["session_id"] = os.urandom(16).hex()

    ip_address = request.headers.get("X-Forwarded-For", request.remote_addr)
    user_agent = request.headers.get("User-Agent", "Unknown")

    log_visitor(ip_address, user_agent, session["session_id"])

    redis_client = get_redis_client()
    page_views = redis_client.incr("page_views") if redis_client else 0

    return f"""
    <html>
    <head>
        <title>Containerized Flask Platform</title>
        <style>
            body {{ font-family: Arial, sans-serif; margin: 40px; background-color: #f4f6f8; }}
            .container {{ background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 12px rgba(0,0,0,0.12); }}
            h1 {{ color: #222; }}
            .info {{ background-color: #e7f3ff; padding: 15px; border-radius: 6px; margin: 20px 0; }}
            .status {{ background-color: #d4edda; padding: 12px; border-radius: 6px; margin: 10px 0; }}
            a {{ color: #0056b3; }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Containerized Flask Platform</h1>
            <div class="info">
                <p><strong>Runtime:</strong> Docker Compose</p>
                <p><strong>Total Visitors:</strong> {get_visitor_count()}</p>
                <p><strong>Page Views:</strong> {page_views}</p>
                <p><strong>Your IP:</strong> {ip_address}</p>
                <p><strong>Session ID:</strong> {session["session_id"][:8]}...</p>
            </div>
            <div class="status">
                <p><strong>Redis:</strong> {"Connected" if redis_client else "Unavailable"}</p>
                <p><strong>SQLite:</strong> Connected</p>
                <p><strong>Nginx:</strong> Reverse proxy enabled</p>
            </div>
            <p>This stack demonstrates Flask, Redis, SQLite persistence, Nginx reverse proxying, Docker networking, and volume-backed storage.</p>
            <p><a href="/visitors">Recent Visitors</a> | <a href="/stats">Statistics</a> | <a href="/health">Health</a></p>
        </div>
    </body>
    </html>
    """


@app.route("/health")
def health():
    redis_client = get_redis_client()
    return jsonify(
        {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "visitors": get_visitor_count(),
            "redis_available": redis_client is not None,
        }
    )


@app.route("/stats")
def stats():
    redis_client = get_redis_client()
    page_views = redis_client.get("page_views") if redis_client else 0

    return jsonify(
        {
            "total_visitors": get_visitor_count(),
            "total_page_views": int(page_views) if page_views else 0,
            "redis_status": "connected" if redis_client else "unavailable",
            "timestamp": datetime.utcnow().isoformat(),
        }
    )


@app.route("/visitors")
def visitors():
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT id, ip_address, visit_time, user_agent, session_id FROM visitors ORDER BY visit_time DESC LIMIT 10")
    rows = cursor.fetchall()
    conn.close()

    table_rows = "".join(
        f"<tr><td>{row[0]}</td><td>{row[1]}</td><td>{row[2]}</td><td>{row[3][:60]}...</td><td>{row[4][:8]}...</td></tr>"
        for row in rows
    )

    return f"""
    <html>
    <head><title>Recent Visitors</title></head>
    <body>
        <h1>Recent Visitors</h1>
        <table border="1" cellpadding="6">
            <tr><th>ID</th><th>IP Address</th><th>Visit Time</th><th>User Agent</th><th>Session</th></tr>
            {table_rows}
        </table>
        <br>
        <a href="/">Back to Home</a>
    </body>
    </html>
    """


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=False)
