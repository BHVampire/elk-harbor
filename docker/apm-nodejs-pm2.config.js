// ecosystem.config.js para PM2
module.exports = {
  apps: [{
    name: "mi-api-node",
    script: "app.js",
    env: {
      NODE_ENV: "production",
      ELASTIC_APM_SERVICE_NAME: "mi-api-node",
      ELASTIC_APM_SECRET_TOKEN: "supersecrettoken",
      ELASTIC_APM_SERVER_URL: "http://tu-ip-docker:8200"
    }
  }]
}