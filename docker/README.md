# ELK Stack Implementation for Enterprise Monitoring

This directory contains all the necessary files to implement a complete ELK Stack monitoring solution, specifically designed for environments with .NET Core APIs on IIS, Node.js with PM2, and SQL Server.

## What is ELK Stack?

ELK Stack is a collection of open-source tools from Elastic that provides a complete solution for collecting, processing, storing, and visualizing logs and metrics:

- **Elasticsearch**: Distributed search and analytics engine based on Apache Lucene
- **Logstash**: Data processor that ingests, transforms, and sends data to Elasticsearch
- **Kibana**: Visualization and exploration platform for data in Elasticsearch
- **Beats**: Lightweight agents for sending data from different sources
- **APM**: Application Performance Monitoring to instrument applications

In this implementation, we've configured the stack to:

- Monitor .NET Core APIs on IIS and Node.js with PM2
- Collect and analyze logs from SQL Server
- Detect errors in business transactions
- Monitor availability and performance of critical services
- Provide real-time alerts for operational issues

## Directory Structure

```
docker/
├── docker-compose.yml              # Main Docker configuration
├── elasticsearch/
│   └── config/
│       └── elasticsearch.yml       # Elasticsearch configuration
├── logstash/
│   ├── config/
│   │   └── logstash.yml            # Logstash configuration
│   └── pipeline/
│       └── main.conf               # Logstash processing pipeline
├── kibana/
│   └── config/
│       └── kibana.yml              # Kibana configuration
├── heartbeat/
│   └── config/
│       └── heartbeat.yml           # Availability monitoring configuration
├── fleet-server/
│   └── tokens/                     # Directory for Fleet Server tokens
├── filebeat-windows.yml            # General log collection configuration
├── filebeat-iis.yml                # IIS logs specific configuration
├── metricbeat-sql-server.yml       # SQL Server monitoring configuration
├── metricbeat-netcore-iis.yml      # .NET Core/IIS monitoring configuration
├── metricbeat-nodejs-pm2.yml       # Node.js/PM2 monitoring configuration
├── apm-netcore-config.json         # APM configuration for .NET Core
├── apm-netcore-setup.cs            # Code to integrate APM in .NET Core
├── apm-nodejs-setup.js             # Code to integrate APM in Node.js
└── apm-nodejs-pm2.config.js        # PM2 configuration with APM
```

## Prerequisites

- Docker and Docker Compose (version 1.29.0+)
- Access to Windows servers with administrator permissions
- Network access between servers and the Docker host
- Minimum recommended resources for Docker:
  - 8GB+ RAM
  - 4+ CPU cores
  - 50GB+ disk space
- For production environments, dedicated servers are recommended

## Implementation Steps

### 1. Docker Environment Setup

1. **Review and adjust configuration files**:
   - Modify passwords in all files (default is "contraseñacompleja123")
   - Adjust IP addresses and hostnames according to your environment (replace "tu-ip-docker", "servidor-netcore", etc.)
   - Adjust memory requirements in `docker-compose.yml` according to your available resources

2. **Create necessary directories for persistent volumes**:
   ```bash
   mkdir -p elasticsearch/data
   ```

3. **Configure memory limits for Elasticsearch** (Linux only):
   ```bash
   sudo sysctl -w vm.max_map_count=262144
   # To make it permanent, edit /etc/sysctl.conf and add:
   # vm.max_map_count=262144
   ```

4. **Start services with Docker Compose**:
   ```bash
   docker-compose up -d
   ```

5. **Verify that services are running**:
   ```bash
   docker-compose ps
   ```

6. **Access Kibana to verify installation**:
   - Open in browser: `http://your-docker-ip:5601`
   - Initial credentials: elastic / contraseñacompleja123

### 2. Configuring Agents on Windows Servers

#### For SQL Server Servers:

1. **Download and install Beats agents**:
   - [Filebeat](https://www.elastic.co/downloads/beats/filebeat) (version compatible with your ELK Stack)
   - [Metricbeat](https://www.elastic.co/downloads/beats/metricbeat) (same version)

2. **Configure the agents**:
   - Copy `filebeat-windows.yml` as `filebeat.yml` to `C:\Program Files\Filebeat\`
   - Copy `metricbeat-sql-server.yml` as `metricbeat.yml` to `C:\Program Files\Metricbeat\`
   - Modify files to update IPs and credentials

3. **Install Windows services**:
   ```powershell
   # Open PowerShell as Administrator
   cd "C:\Program Files\Filebeat"
   .\install-service-filebeat.ps1

   cd "C:\Program Files\Metricbeat"
   .\install-service-metricbeat.ps1
   ```

4. **Start services**:
   ```powershell
   Start-Service filebeat
   Start-Service metricbeat
   ```

5. **Check logs to ensure agents are connecting**:
   ```powershell
   Get-Content "C:\ProgramData\filebeat\logs\filebeat"
   Get-Content "C:\ProgramData\metricbeat\logs\metricbeat"
   ```

#### For .NET Core/IIS Servers:

1. **Configure Filebeat and Metricbeat for IIS**:
   - Install Filebeat and Metricbeat as in the previous section
   - Use `filebeat-iis.yml` for Filebeat
   - Use `metricbeat-netcore-iis.yml` for Metricbeat
   - Ensure Filebeat has permissions to read IIS logs

2. **Integrate APM in your .NET Core applications**:
   - Install the NuGet package for APM:
     ```
     Install-Package Elastic.Apm.NetCoreAll
     ```
   - Integrate APM in your application following the example in `apm-netcore-setup.cs`
   - Configure APM using the format in `apm-netcore-config.json` (add it to your `appsettings.json`)

3. **IIS-specific configurations**:
   - Ensure your application's Application Pool has permissions to generate logs
   - For .NET Framework applications, also use the `Elastic.Apm.AspNetFullFramework` package
   - Consider activating HTTP module logging for advanced diagnostics:
     ```xml
     <!-- In web.config -->
     <system.webServer>
       <httpLogging dontLog="false" selectiveLogging="LogAll" />
     </system.webServer>
     ```

4. **Customize specific monitoring for your APIs**:
   - Adjust Application Pool mappings in `metricbeat-netcore-iis.yml`
   - Update health check endpoints in `heartbeat.yml`

#### For Node.js/PM2 Servers:

1. **Install the APM agent**:
   ```bash
   npm install elastic-apm-node --save
   ```

2. **Integrate APM in your application**:
   - Follow the example in `apm-nodejs-setup.js` to instrument your API
   - If using Express.js, make sure to register the APM middleware before any other middleware

3. **Configure PM2 with APM**:
   - Use the `apm-nodejs-pm2.config.js` file as a base for your configuration
   - Run your application with PM2 using this file:
     ```bash
     pm2 start ecosystem.config.js
     ```

4. **Install and configure Metricbeat**:
   - Follow the general steps for installing Beats on Windows
   - Use `metricbeat-nodejs-pm2.yml` as configuration
   - Make sure to enable inspection in Node.js for advanced metrics:
     ```bash
     # Add to your startup script or ecosystem.config.js
     --inspect=127.0.0.1:9229
     ```

### 3. Dashboard and Alert Configuration

#### Initial Dashboards:

1. Access Kibana (`http://your-docker-ip:5601`)
2. Navigate to Stack Management > Saved Objects > Import
3. Import your custom dashboards or use predefined ones:
   - Navigate to Management > Stack Management > Kibana > Saved Objects
   - Click on "Import" and upload any dashboard JSON file

#### Alert Configuration:

1. Navigate to Stack Management > Rules and Connectors
2. Configure connectors for notifications (email, Slack, webhook, etc.)
3. Create rules for critical alerts:
   - **API Availability**: 
     - Type: Threshold
     - Condition: `heartbeat.monitors.status` is `down` for more than 2 minutes
   - **SQL Server Errors**:
     - Type: Threshold
     - Condition: Tags include `sqlserver` AND `error_detected`
   - **Business Errors**:
     - Type: Threshold
     - Condition: Tags include `financial_error` or `business_error`
   - **High CPU/Memory Usage**:
     - Type: Threshold
     - Condition: `system.cpu.total.pct` > 85% for more than 5 minutes

### 4. Advanced Configuration and Customization

#### Security

1. **Change default passwords**:
   ```bash
   # Using Elasticsearch REST API
   curl -X POST "http://localhost:9200/_security/user/elastic/_password" -H 'Content-Type: application/json' -d'
   {
     "password" : "new-secure-password"
   }
   '
   ```

2. **Configure HTTPS**:
   - Generate SSL certificates for your environment
   - Update configuration files to use HTTPS
   - Update all URLs in agent configurations

3. **Network security**:
   - Limit access to Elasticsearch and Kibana to specific IPs only
   - Configure a reverse proxy (like Nginx) for external access to Kibana

#### Optimization

1. **Index lifecycle policies**:
   - Navigate to Stack Management > Index Lifecycle Policies
   - Create policies to handle data growth:
     - Hot phase: Recent indices for fast searches
     - Warm phase: Older indices with fewer replicas
     - Cold phase: Archiving of historical data 
     - Delete phase: Deletion of very old data

2. **Resource tuning**:
   - Monitor Elasticsearch RAM and CPU usage
   - Adjust JVM configuration based on observed usage:
     ```yaml
     # In elasticsearch.yml or as environment variable
     ES_JAVA_OPTS: "-Xms4g -Xmx4g"
     ```

3. **Logstash pipeline optimization**:
   - Adjust the number of workers and batch size according to data volume
   - Use multiple pipelines for different types of data

#### Industry-Specific Customizations

1. **Fraud detection**:
   - Implement specific rules in the Logstash filter
   - Configure Machine Learning for anomaly detection

2. **Regulatory compliance**:
   - Configure log retention according to regulatory requirements
   - Implement auditing of access to sensitive data

3. **Transaction monitoring**:
   - Create specific visualizations to monitor transaction volume
   - Configure alerts for unusual patterns

## Maintenance and Troubleshooting

### Regular Maintenance

1. **Component updates**:
   - Check the [compatibility matrix](https://www.elastic.co/support/matrix) before updating
   - Update in the following order: Elasticsearch, Kibana, Logstash, Beats

2. **Backup**:
   - Configure Snapshot Repository in Elasticsearch
   - Schedule regular backups of configurations and critical data

3. **Stack monitoring**:
   - Use the built-in monitoring module to monitor the health of the stack
   - Configure alerts for issues in the ELK stack itself

### Common Troubleshooting

1. **Elasticsearch won't start**:
   - Check virtual memory limits:
     ```bash
     sysctl -w vm.max_map_count=262144
     ```
   - Check logs:
     ```bash
     docker-compose logs elasticsearch
     ```

2. **Logstash not processing data**:
   - Check connectivity:
     ```bash
     telnet your-docker-ip 5044
     ```
   - Check pipeline syntax:
     ```bash
     docker-compose exec logstash logstash --config.test_and_exit -f /usr/share/logstash/pipeline/main.conf
     ```

3. **Beats not sending data**:
   - Run with detailed logs:
     ```powershell
     .\filebeat.exe -e -c filebeat.yml
     ```
   - Check permissions and network connectivity

4. **Kibana not showing data**:
   - Verify that indices exist:
     ```bash
     curl http://localhost:9200/_cat/indices
     ```
   - Create index patterns manually if needed

5. **Issues with IIS and Application Pools**:
   - Verify that application pools have the correct process model
   - Make sure IIS is generating logs in the configured locations
   - Check log access permissions for Filebeat

## Specific Use Cases for Business Applications

### Business Transaction Monitoring

1. **Transaction error detection**:
   - Use the configured Logstash filters to detect patterns such as:
     ```
     if [message] =~ "(?i)payment|transfer|account" and [message] =~ "(?i)error|failed|denied" {
       # Business error classification
     }
     ```

2. **Transaction volume visualization**:
   - Create specific dashboards to monitor:
     - Transaction volume by hour/day
     - Error rate in transactions
     - Average response time

### Anomaly Detection

1. **Machine Learning configuration**:
   - Activate X-Pack ML features
   - Create jobs for anomaly detection in:
     - CPU/memory usage patterns
     - Unusual transaction volume
     - Abnormal response times

2. **Anomaly-based alerts**:
   - Configure alerts when anomalies are detected
   - Integrate with ticketing systems or incident management tools

## Migration to Production

### Considerations for Production Environments

1. **Scalability**:
   - Consider implementing an Elasticsearch cluster with multiple nodes
   - Separate nodes by role (master, data, ingest, coordinating)

2. **High availability**:
   - Implement multiple master nodes
   - Distribute data nodes across different physical servers
   - Configure adequate replicas for indices

3. **Security**:
   - Implement TLS/SSL for all communications
   - Configure RBAC (role-based access control)
   - Implement access auditing

4. **Performance**:
   - Use SSD storage for data nodes
   - Separate hot/warm/cold nodes to optimize costs
   - Adjust sharding according to expected data volume

## Next Steps and Monitoring Evolution

Once you have the basic system working with IIS-level monitoring (which automatically captures metrics and logs from all your APIs without individual instrumentation), you can consider these next steps:

### Phase 1: Basic Monitoring (Current)
- Infrastructure-level monitoring (CPU, memory, disk)
- Collection of IIS, SQL Server, and Windows logs
- Basic availability monitoring with Heartbeat
- Alerts for critical availability issues

### Phase 2: Advanced Monitoring
- Selective APM instrumentation of critical APIs (starting with the most important ones)
- Development of custom dashboards for business KPIs
- Implementation of more specific alerts based on business patterns
- Correlation of events across different systems

### Phase 3: Operational Intelligence
- Implementation of Machine Learning for anomaly detection
- Automation of responses to common incidents
- Integration with incident management systems
- Development of advanced business metrics

### Phase 4: Transformation and Optimization
- Use of historical data for resource optimization
- Implementation of capacity forecasts
- Integration with CI/CD processes for automatic deployment monitoring
- Development of predictive models for anomalous behaviors

### Long-term Considerations
- Periodic evaluation of data volume and associated costs
- Refinement of retention policies according to data value
- Balance between monitoring coverage and system overhead
- Continuous team training in analysis and incident response

# Catalog of Expansions and Possibilities

This catalog presents different ways to expand and enhance your ELK Stack implementation, from practical integrations to advanced use cases.

## Integrations and Plugins

### Security and Regulatory Compliance

- **Elastic Security**:
  - Threat detection based on rules and machine learning
  - Security alerts on anomalous behaviors
  - SIEM integration for security analysis

- **PCI-DSS/GDPR Compliance**:
  - Monitoring of access to sensitive data
  - Auditing of changes in critical configurations
  - Automated compliance reports

### Advanced Analytics

- **Elastic Machine Learning**:
  - Fraud detection in transactions
  - Performance issue prediction
  - Usage pattern analysis for optimization

- **Canvas and Vega**:
  - Interactive dashboards for business KPIs
  - Custom visualizations for transaction analysis
  - Real-time reports for executives

### Performance Improvements

- **Cross-Cluster Replication**:
  - Geographic replication for high availability
  - Disaster recovery

- **Hot-Warm-Cold Architecture**:
  - Storage cost optimization
  - Improved performance for frequent queries

### Data Enrichment

- **Logstash Enrichment Filters**:
  - Transaction enrichment with customer data
  - Automatic event categorization
  - Event correlation across services

- **Processor Pipelines**:
  - Data transformation for specific analysis
  - Extraction of business metrics from technical logs

## Specialized Use Cases

### Fraud Detection

- **Real-time Risk Scoring System**:
  - Creation of user profiles based on behavior
  - Real-time detection of unusual patterns
  - Automated alerts for suspicious transactions

- **Geographic Pattern Analysis**:
  - Detection of access from unusual locations
  - Visualization of geographic transaction patterns
  - Alerts for rapid location changes

### Business Intelligence

- **Business KPI Dashboards**:
  - Transaction volume by type, region, product
  - Error rate and response times by service
  - Usage trends and product adoption

- **Predictive Analysis**:
  - Transaction volume forecasting
  - Load peak prediction for capacity planning
  - Early detection of potential issues

### User Experience Monitoring

- **User Journey Monitoring**:
  - Tracking of complete user sessions
  - Measurement of perceived response times
  - Detection of abandonments and friction points

- **Real User Monitoring (RUM)**:
  - Integration with web and mobile applications
  - Performance measurement from the user perspective
  - Correlation between user experience and backend behavior

## Infrastructure Expansions

### Distributed Architectures

- **Multi-Node Elasticsearch Cluster**:
  - Role separation (master, data, ingest, coordinating)
  - Resource optimization by node type
  - High availability and fault tolerance

- **Distributed Logstash with Kafka**:
  - Message buffer for traffic peaks
  - Parallel processing for higher throughput
  - Resilience to component failures

### Integration with Other Systems

- **Ticketing System Integration**:
  - Automatic ticket creation in JIRA, ServiceNow
  - Ticket enrichment with contextual data
  - Incident lifecycle tracking

- **Webhooks and Alerting**:
  - Integration with Slack, Microsoft Teams, Discord
  - SMS/Email notification systems
  - PagerDuty integration for on-call

## Complementary Tools from the Elastic Ecosystem

- **Fleet**: Centralized management of Elastic agents
- **Elastic Maps**: Geospatial visualizations for regional analysis
- **Kibana Lens**: Simplified visualization creation for non-technical users
- **Elastic Observability**: Unified solution for logs, metrics, and APM
- **Elastic Enterprise Search**: Search across all enterprise data

## Experimental Features

- **Federated Learning**:
  - Distributed machine learning models
  - Learning without centralizing sensitive data

- **Sentiment Analysis**:
  - Natural language processing for customer feedback
  - Automatic detection of emerging issues

- **Digital Twin Analytics**:
  - Virtual modeling of business systems
  - Scenario simulation for testing and planning

## Resources and Community

- **Elastic Stack Exchange**: Q&A community
- **Elastic Meetups**: Local groups and online events
- **Elastic Blogs and Webinars**: Regular educational content
- **Elastic Cloud Enterprise**: Hosted option for future growth

## References

- [Official Elastic Documentation](https://www.elastic.co/guide/index.html)
- [Elasticsearch Quick Start Guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/getting-started.html)
- [Logstash Reference](https://www.elastic.co/guide/en/logstash/current/index.html)
- [Kibana Guide](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Filebeat Documentation](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
- [Metricbeat Documentation](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html)
- [.NET APM Guide](https://www.elastic.co/guide/en/apm/agent/dotnet/current/index.html)
- [Node.js APM Guide](https://www.elastic.co/guide/en/apm/agent/nodejs/current/index.html)