# ElkHarbor

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Elastic Stack: 8.10.4](https://img.shields.io/badge/Elastic%20Stack-8.10.4-00bfb3)](https://www.elastic.co/elastic-stack)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows-server)

A comprehensive enterprise monitoring solution powered by the ELK Stack (Elasticsearch, Logstash, Kibana), designed for modern application environments with .NET Core on IIS, Node.js with PM2, and SQL Server.

![ELK Stack Logo](https://www.elastic.co/static-res/images/elastic-logo-200.png)

## 📋 Overview

This project provides a complete solution for implementing and operating an ELK stack (Elasticsearch, Logstash, Kibana) in a business environment. It's specifically designed to monitor:

- .NET Core APIs running on IIS
- Node.js services managed with PM2
- SQL Server databases
- Business transactions and error detection

The project includes optimized configurations and automation tools for deployment and maintenance, with specialized configurations for financial services that can be adapted to other industries.

## 🚀 Main Components

The repository is organized into three main components:

### 🐳 Docker

Contains all necessary files to implement the complete ELK stack using Docker:

- Elasticsearch (storage and search)
- Logstash (data processing)
- Kibana (visualization)
- APM Server (application performance monitoring)
- Fleet Server (agent management)
- Heartbeat (availability monitoring)

### 🤖 Ansible

Playbooks and configurations to automate the deployment of monitoring agents on Windows servers:

- Filebeat installation for log collection
- Metricbeat installation for system metrics
- Specific configurations for IIS, SQL Server, and Node.js

### ☁️ Terraform

Configurations to provision infrastructure on Hetzner Cloud (adaptable to other providers):

- Server definitions optimized for ELK
- Network and firewall configuration
- Persistent data volumes

## 🛠️ Use Cases

This monitoring stack is optimized for several enterprise use cases:

- Detection of errors in business transactions
- API and service performance monitoring
- Real-time alerts for critical issues
- Usage and performance pattern analysis
- Compliance with logging requirements for auditing

## 🏗️ Architecture

The architecture consists of:

1. **ELK Core** (running on Docker):
   - Elasticsearch: Distributed database for storage and search
   - Logstash: Data processor with specific filters for business events
   - Kibana: Visualization interface and dashboards

2. **Server Agents** (managed with Ansible):
   - Filebeat: Collection of application logs, SQL Server and IIS
   - Metricbeat: Collection of system metrics
   - APM Agents: Optional instrumentation for applications

3. **Availability Monitoring**:
   - Heartbeat: Verification of critical endpoints
   - Alerts configured for immediate notification

## 📊 Key Features

- **Zero-instrumentation monitoring**: Start by monitoring all your services at the IIS level without needing to modify each API
- **Business error detection**: Custom filters to identify issues in transactions
- **Scalability**: Configured to grow from a development environment to production
- **Complete automation**: Automated deployment and configuration with Ansible
- **Infrastructure as code**: Infrastructure definition with Terraform
- **Adaptable to different industries**: While some examples focus on financial services, the core setup works for any business domain

## 🚦 Getting Started

To begin with this implementation:

1. **Basic setup**: 
   - Start with the Docker deployment for the central stack
   - See [docker/README.md](docker/README.md) for detailed instructions

2. **Agent deployment**:
   - Use Ansible to install and configure agents on servers
   - See [ansible/README.md](ansible/README.md) for step-by-step process

3. **Cloud infrastructure** (optional):
   - For deployment on Hetzner Cloud (or adaptable to other providers)
   - See [terraform/README.md](terraform/README.md) for instructions

## 🔍 Advanced Monitoring

This project also includes configurations for advanced use cases:

- **Machine Learning**: Anomaly detection and problem prediction
- **Fraud detection**: Models to identify suspicious patterns
- **Business visualizations**: Dashboards for business KPIs

## 🗺️ Roadmap

Future development of ElkHarbor will include:

### Industry-Specific Examples

Pre-configured templates for various industries will be added:

- **Financial Services** - With transaction monitoring and fraud detection
- **E-commerce** - Shopping cart and order pipeline monitoring
- **Healthcare** - HIPAA-compliant monitoring setups
- **High-volume APIs** - Optimized configurations for high throughput services

### Additional Integrations

Planned integrations include:

- Kubernetes deployment options with Helm charts
- CI/CD pipeline examples
- Alert integration with additional services

Contributions to these areas are especially welcome!

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📜 License

This project is licensed under the [MIT License](LICENSE).

## 📚 References

- [Official Elastic Documentation](https://www.elastic.co/guide/index.html)
- [Docker Documentation](https://docs.docker.com/)
- [Ansible for Windows](https://docs.ansible.com/ansible/latest/user_guide/windows_usage.html)
- [Terraform with Hetzner](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)