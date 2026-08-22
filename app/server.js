const express = require("express");
const os = require("os");
const client = require("prom-client");

const app = express();
app.use((req, res, next) => {
  const start = Date.now();

  res.on("finish", () => {
    const duration = Date.now() - start;

    console.log(
      JSON.stringify({
        timestamp: new Date().toISOString(),
        method: req.method,
        path: req.originalUrl,
        status: res.statusCode,
        duration_ms: duration,
      })
    );
  });

  next();
});

const register = client.register;

client.collectDefaultMetrics({
    register
});
const PORT = process.env.PORT || 3000;

// HEALTH check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "UP"
  });
});

// INFO check endpoint 
app.get("/info", (req, res) => {
  res.json({
    application: "devops-kubernetes-project",
    environment: process.env.APP_ENV || "development",
    version: process.env.APP_VERSION || "v1",
    hostname: os.hostname(),
    time: new Date()
  });
});

// SECRET check endpoint
app.get("/secret", (req, res) => {
  res.json({
    dbUser: process.env.DB_USER,
    dbPassword: "********",
    apiKeyConfigured: !!process.env.API_KEY
  });
});

app.get("/", (req, res) => {
  res.send(`
    <h1>🚀 DevOps Kubernetes Project</h1>

    <h2>Version 2</h2>

    <p>Rolling Update Demo</p>
    <p>Environment: ${process.env.APP_ENV || "development"}</p>
    <p>Version: ${process.env.APP_VERSION || "v1"}</p>
    <p>Hostname: ${os.hostname()}</p>
    <p>Time: ${new Date()}</p>
    <p>Status: Healthy</p>
  `);
});

app.get("/metrics", async (req, res) => {
    res.set("Content-Type", register.contentType);
    res.end(await register.metrics());
});

app.listen(PORT, () => {
  console.log(`Application running on port ${PORT}`);
});