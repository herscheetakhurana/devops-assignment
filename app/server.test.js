const request = require("supertest");
const app = require("./server");

describe("GET /health", () => {
  it("should return 200 with healthy status", async () => {
    const res = await request(app).get("/health");
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe("healthy");
  });
});

describe("GET /api/info", () => {
  it("should return app info", async () => {
    const res = await request(app).get("/api/info");
    expect(res.statusCode).toBe(200);
    expect(res.body.app).toBe("devops-sample-app");
  });
});
