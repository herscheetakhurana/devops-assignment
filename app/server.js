const express = require("express");
const path = require("path");
const app = express();

const PORT = process.env.PORT || 3000;
const APP_VERSION = process.env.APP_VERSION || "1.0.0";
const ENV = process.env.NODE_ENV || "development";

app.use(express.static(path.join(__dirname, "public")));
app.use(express.json());

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

app.get("/api/info", (req, res) => {
  res.json({
    app: "devops-sample-app",
    version: APP_VERSION,
    environment: ENV,
    hostname: require("os").hostname(),
    nodeVersion: process.version,
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT} | env: ${ENV} | version: ${APP_VERSION}`);
});

module.exports = app;
