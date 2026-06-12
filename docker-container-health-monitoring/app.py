from flask import Flask, jsonify
import time

app = Flask(__name__)

app_healthy = True
start_time = time.time()

@app.route('/')
def home():
    return jsonify({
        "message":"Docker Health Monitoring",
        "status":"running",
        "uptime":int(time.time()-start_time)
    })

@app.route('/health')
def health():

    global app_healthy

    if app_healthy:
        return jsonify({
            "status":"healthy",
            "uptime":int(time.time()-start_time)
        }),200

    return jsonify({
        "status":"unhealthy"
    }),500

@app.route('/make-unhealthy')
def unhealthy():
    global app_healthy
    app_healthy=False
    return jsonify({"message":"Application unhealthy"})

@app.route('/make-healthy')
def healthy():
    global app_healthy
    app_healthy=True
    return jsonify({"message":"Application healthy"})

if __name__ == "__main__":
    app.run(host="0.0.0.0",port=5000)
