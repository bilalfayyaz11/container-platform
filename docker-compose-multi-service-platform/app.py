from flask import Flask, request, jsonify
import psycopg2
import redis
import os
import json
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'your-secret-key-change-in-production'

DB_HOST = os.environ.get('DB_HOST', 'db')
DB_NAME = os.environ.get('DB_NAME', 'webapp')
DB_USER = os.environ.get('DB_USER', 'postgres')
DB_PASS = os.environ.get('DB_PASS', 'password')

REDIS_HOST = os.environ.get('REDIS_HOST', 'redis')
REDIS_PORT = int(os.environ.get('REDIS_PORT', 6379))

try:
    r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
except Exception:
    r = None

def get_db_connection():
    try:
        return psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS
        )
    except:
        return None

@app.route('/')
def home():
    try:
        views = r.incr('page_views')
    except:
        views = 'N/A'

    return jsonify({
        'message': 'Welcome to Multi-Container Web App!',
        'page_views': views,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/users', methods=['GET', 'POST'])
def users():
    conn = get_db_connection()

    if not conn:
        return jsonify({'error':'Database connection failed'}),500

    if request.method == 'POST':
        data = request.get_json()

        name = data.get('name')
        email = data.get('email')

        cur = conn.cursor()

        cur.execute(
            "INSERT INTO users (name,email,created_at) VALUES (%s,%s,%s)",
            (name,email,datetime.now())
        )

        conn.commit()

        cur.close()
        conn.close()

        return jsonify({'message':'User created successfully'}),201

    cur = conn.cursor()

    cur.execute(
        "SELECT name,email,created_at FROM users ORDER BY created_at DESC"
    )

    users = cur.fetchall()

    cur.close()
    conn.close()

    return jsonify({
        "users":[
            {
                "name":u[0],
                "email":u[1],
                "created_at":u[2].isoformat()
            }
            for u in users
        ]
    })

@app.route('/health')
def health():

    db_status = "healthy"

    try:
        conn = get_db_connection()
        conn.close()
    except:
        db_status = "unhealthy"

    redis_status = "healthy"

    try:
        r.ping()
    except:
        redis_status = "unhealthy"

    return jsonify({
        "status":"running",
        "database":db_status,
        "redis":redis_status,
        "timestamp":datetime.now().isoformat()
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
