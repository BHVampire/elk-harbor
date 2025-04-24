// Instalar primero: npm install elastic-apm-node --save

// Al inicio de tu aplicación Node.js
const apm = require('elastic-apm-node').start({
  serviceName: 'mi-api-node',
  secretToken: 'supersecrettoken',
  serverUrl: 'http://tu-ip-docker:8200',
  environment: 'production',
  logLevel: 'error',
  captureBody: 'all',
  captureHeaders: true,
  metricsInterval: '15s'
});

// Si usas Express.js
const express = require('express');
const app = express();

// Registrar APM middleware
app.use(apm.middleware.connect());

// Resto de tu aplicación...