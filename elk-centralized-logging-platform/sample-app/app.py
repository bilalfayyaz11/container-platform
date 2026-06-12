from flask import Flask, jsonify
import logging
import random
from datetime import datetime

app = Flask(__name__)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)

logger = logging.getLogger(__name__)

@app.route('/')
def home():
    logger.info("Home page accessed")
    return jsonify({
        "message":"Welcome to Sample App",
        "timestamp":datetime.now().isoformat(),
        "status":"success"
    })

@app.route('/api/data')
def data():
    log_level = random.choice(["info","warning","error"])

    if log_level == "info":
        logger.info("Data endpoint accessed successfully")
    elif log_level == "warning":
        logger.warning("Data endpoint accessed with potential issues")
    else:
        logger.error("Data endpoint encountered an error")

    return jsonify({
        "data":[1,2,3,4,5],
        "timestamp":datetime.now().isoformat(),
        "log_level":log_level
    })

@app.route('/health')
def health():
    logger.info("Health check performed")
    return jsonify({
        "status":"healthy",
        "timestamp":datetime.now().isoformat()
    })

if __name__ == "__main__":
    logger.info("Starting Sample Application")
    app.run(host="0.0.0.0",port=5000)
