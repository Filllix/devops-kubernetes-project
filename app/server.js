const express = require("express");
const os = require("os");
const client = require("prom-client");

const app = express();

const register = client.register;

const httpRequestsTotal = new client.Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"],
});

const httpRequestDurationSeconds = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "HTTP request duration in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
});

app.use((req, res, next) => {
  const start = process.hrtime.bigint();

  res.on("finish", () => {
    const durationSeconds =
      Number(process.hrtime.bigint() - start) / 1_000_000_000;

    const route = req.route?.path || req.path || "unknown";

    httpRequestsTotal.inc({
      method: req.method,
      route: route,
      status_code: res.statusCode,
    });

    httpRequestDurationSeconds.observe(
      {
        method: req.method,
        route: route,
        status_code: res.statusCode,
      },
      durationSeconds
    );

    console.log(
      JSON.stringify({
        timestamp: new Date().toISOString(),
        method: req.method,
        path: req.originalUrl,
        status: res.statusCode,
        duration_ms: Math.round(durationSeconds * 1000),
      })
    );
  });

  next();
});

client.collectDefaultMetrics({
  register,
});

const PORT = process.env.PORT || 3000;

// HEALTH check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "UP",
  });
});

// INFO check endpoint
app.get("/info", (req, res) => {
  res.json({
    application: "devops-kubernetes-project",
    environment: process.env.APP_ENV || "development",
    version: process.env.APP_VERSION || "v1",
    hostname: os.hostname(),
    time: new Date(),
  });
});

// SECRET check endpoint
app.get("/secret", (req, res) => {
  res.json({
    dbUser: process.env.DB_USER,
    dbPassword: "********",
    apiKeyConfigured: !!process.env.API_KEY,
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

app.get("/error", (req, res) => {
  res.status(500).json({
    status: "ERROR",
    message: "Intentional test error",
  });
});

app.listen(PORT, () => {
  console.log(`Application running on port ${PORT}`);
});