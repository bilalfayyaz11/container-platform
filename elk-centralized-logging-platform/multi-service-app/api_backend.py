from flask import Flask, jsonify
import logging

app = Flask(__name__)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/api/users')
def users():
    logger.info("Users API called")
    return jsonify({"users":["Alice","Bob","Charlie"]})

@app.route('/api/orders')
def orders():
    logger.info("Orders API called")
    return jsonify({
        "orders":[
            {"id":1,"item":"laptop"},
            {"id":2,"item":"mouse"}
        ]
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0",port=5000)
