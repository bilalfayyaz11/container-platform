from flask import Flask, jsonify
import os
import redis

app = Flask(__name__)

APP_NAME = os.getenv("APP_NAME", "container-cicd-service")
APP_VERSION = os.getenv("APP_VERSION", "0.0.0")
APP_ENV = os.getenv("APP_ENV", "development")
REDIS_URL = os.getenv("REDIS_URL")


def get_counter():
    if not REDIS_URL:
        return 0

    client = redis.from_url(REDIS_URL, decode_responses=True)
    return client.incr("request_counter")


@app.route("/")
def index():
    counter = get_counter()
    return jsonify({
        "name": APP_NAME,
        "version": APP_VERSION,
        "environment": APP_ENV,
        "request_counter": counter
    }), 200


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    }), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
