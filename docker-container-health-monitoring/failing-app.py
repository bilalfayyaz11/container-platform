from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message":"This app intentionally fails health checks"})

@app.route('/health')
def health():
    return jsonify({
        "status":"unhealthy",
        "error":"Deliberate health check failure"
    }),500

if __name__ == "__main__":
    app.run(host="0.0.0.0",port=5000)
