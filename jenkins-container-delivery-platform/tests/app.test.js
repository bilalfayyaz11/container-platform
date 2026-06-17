const request = require("supertest");
const app = require("../app");

describe("Jenkins container pipeline service", () => {
  test("GET / returns pipeline message", async () => {
    const response = await request(app).get("/");

    expect(response.status).toBe(200);
    expect(response.body.message).toBe("Hello from a Jenkins container pipeline");
    expect(response.body.version).toBe("1.0.0");
  });

  test("GET /health returns healthy status", async () => {
    const response = await request(app).get("/health");

    expect(response.status).toBe(200);
    expect(response.body.status).toBe("healthy");
  });
});
