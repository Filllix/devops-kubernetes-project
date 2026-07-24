const express = require("express");
const os = require("os");

const app = express();
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

app.listen(PORT, () => {
  console.log(`Application running on port ${PORT}`);
});