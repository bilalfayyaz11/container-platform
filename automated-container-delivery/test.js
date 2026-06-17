const http = require("http");
const { spawn } = require("child_process");

const appProcess = spawn("node", ["app.js"], {
  env: { ...process.env, PORT: "3000" },
  stdio: "inherit"
});

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function requestHealth() {
  return new Promise((resolve, reject) => {
    const req = http.request(
      {
        hostname: "localhost",
        port: 3000,
        path: "/health",
        method: "GET",
        timeout: 5000
      },
      (res) => {
        let data = "";

        res.on("data", (chunk) => {
          data += chunk;
        });

        res.on("end", () => {
          try {
            const response = JSON.parse(data);
            if (res.statusCode === 200 && response.status === "healthy") {
              resolve();
            } else {
              reject(new Error(`Unexpected response: ${data}`));
            }
          } catch (error) {
            reject(new Error(`Invalid JSON response: ${data}`));
          }
        });
      }
    );

    req.on("error", reject);
    req.on("timeout", () => {
      req.destroy(new Error("Request timed out"));
    });

    req.end();
  });
}

(async () => {
  try {
    console.log("Starting health check test...");
    await wait(3000);
    await requestHealth();
    console.log("Health check passed.");
    appProcess.kill();
    process.exit(0);
  } catch (error) {
    console.error("Health check failed:", error.message);
    appProcess.kill();
    process.exit(1);
  }
})();
