# ShopSphere — Production-Grade E-Commerce DevOps Project

ShopSphere is a containerized three-tier e-commerce application built to demonstrate a production-oriented DevOps workflow using Docker Compose, Nginx, PostgreSQL, Redis, Prometheus, Grafana, Loki, Promtail, GitHub Actions, automated backups, and Blue/Green deployment.

The project focuses not only on running an application in containers, but also on monitoring, centralized logging, performance testing, deployment automation, rollback, persistence, and basic security practices.

---

## Architecture

```text
                         Users
                           |
                           v
                    +-------------+
                    |    Nginx    |
                    | Reverse     |
                    | Proxy :80   |
                    +------+------+
                           |
              +------------+-------------+
              |                          |
              v                          v
        +-----------+          +-------------------+
        | Frontend  |          | Active Backend    |
        | React     |          | Blue OR Green     |
        | + Nginx   |          | FastAPI :8000     |
        +-----------+          +---------+---------+
                                         |
                              +----------+----------+
                              |                     |
                              v                     v
                       +-------------+       +-------------+
                       | PostgreSQL  |       |    Redis    |
                       | Database    |       |    Cache    |
                       +-------------+       +-------------+


Monitoring:
FastAPI /metrics
      |
      v
 Prometheus
      |
      v
   Grafana


Centralized Logging:
Docker Container Logs
      |
      v
   Promtail
      |
      v
     Loki
      |
      v
 Grafana Explore
```

---

## Technology Stack

| Area | Technology |
|---|---|
| Frontend | React + Vite |
| Backend | FastAPI + Python |
| Database | PostgreSQL 16 |
| Cache | Redis 7 |
| Reverse Proxy | Nginx |
| Containers | Docker |
| Orchestration | Docker Compose |
| Metrics | Prometheus |
| Dashboard | Grafana |
| Logging | Loki + Promtail |
| CI | GitHub Actions |
| Load Testing | ApacheBench |
| Deployment | Blue/Green deployment |
| Version Control | Git + GitHub |

---

## Project Structure

```text
ecommerce-devops/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── backend/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── backups/
├── database/
│   └── init.sql
├── frontend/
│   ├── Dockerfile
│   └── ...
├── monitoring/
│   ├── prometheus.yml
│   ├── loki/
│   └── promtail/
├── nginx/
│   └── default.conf
├── scripts/
│   ├── backup.sh
│   ├── deploy.sh
│   ├── rollback.sh
│   └── switch-backend.sh
├── .env.example
├── .gitignore
├── docker-compose.yml
└── README.md
```

---

## Application Features

The FastAPI backend provides endpoints for application health, database connectivity, products, instance identification, and Prometheus metrics.

Important endpoints include:

```text
/health
/db-health
/products
/instance
/metrics
```

The `/products` endpoint uses Redis caching to reduce repeated database access.

---

## Docker Compose Deployment

The complete application stack is managed through Docker Compose.

Start the stack:

```bash
docker compose up -d
```

Check running services:

```bash
docker compose ps
```

Stop the stack:

```bash
docker compose down
```

Persistent Docker volumes are used for PostgreSQL, Redis, Prometheus, Grafana, and Loki data.

---

## Environment Configuration

Create your local environment file from the example:

```bash
cp .env.example .env
```

Then configure the required values.

Example variables:

```env
POSTGRES_DB=ecommerce_db
POSTGRES_USER=ecommerce_user
POSTGRES_PASSWORD=change_me

DB_HOST=postgres
DB_PORT=5432

REDIS_HOST=redis
REDIS_PORT=6379
```

The real `.env` file is excluded from Git through `.gitignore`.

---

## Nginx Reverse Proxy

Nginx acts as the public entry point for the application.

```text
/       -> React frontend
/api/   -> Active FastAPI Blue/Green backend
```

The backend containers are not directly exposed to the host.

Nginx also provides:

- Reverse proxy routing
- Gzip compression
- Static asset caching
- Forwarded request headers
- Graceful reload during Blue/Green traffic switching

---

## Blue/Green Deployment

Two backend environments are maintained:

```text
backend-blue
backend-green
```

Only one receives production traffic at a time.

The deployment workflow is:

```text
Current Active Backend
        |
        v
Build/Recreate Inactive Backend
        |
        v
Wait for Health Check
        |
        v
Update Nginx Upstream
        |
        v
Validate Nginx Configuration
        |
        v
Graceful Nginx Reload
        |
        v
New Backend Becomes Active
```

Run a deployment:

```bash
./scripts/deploy.sh
```

The script detects the active environment and deploys the new version to the inactive environment before switching traffic.

---

## Rollback

The previous backend remains available after deployment.

Rollback can therefore switch traffic back without rebuilding the previous environment.

```bash
./scripts/rollback.sh
```

The rollback process:

1. Detects the currently active backend.
2. Identifies the previous environment.
3. Checks that the rollback target is running.
4. Verifies its health.
5. Switches Nginx traffic.
6. Gracefully reloads Nginx.
7. Verifies application health.

Blue/Green deployment and rollback were successfully demonstrated with health-checked traffic switching.

---

## Monitoring

Prometheus collects metrics from the FastAPI `/metrics` endpoint.

The Grafana dashboard monitors:

- Backend availability
- Backend memory usage
- Product API requests
- Average Product API latency

Prometheus uses Docker DNS service discovery to monitor both Blue and Green backend environments.

---

## Centralized Logging

Application and container logs are collected through:

```text
Docker Logs
    |
 Promtail
    |
   Loki
    |
 Grafana Explore
```

Example LogQL query:

```logql
{job="docker"} |= "GET /products"
```

This was verified by retrieving FastAPI request logs such as successful `GET /products` requests from Grafana Explore.

---

## PostgreSQL Backup

A backup script is available at:

```text
scripts/backup.sh
```

Run:

```bash
./scripts/backup.sh
```

The script generates timestamped PostgreSQL dumps inside the `backups/` directory.

Database restoration was also tested using a temporary database to confirm that backed-up product records could be recovered successfully.

Backup `.sql` files are excluded from Git.

---

## Performance Testing

ApacheBench was used to send concurrent requests through the production Nginx path:

```bash
ab -n 1000 -c 20 http://localhost/api/products
```

Observed test result:

```text
Complete requests:      1000
Failed requests:        0
Requests per second:    110.58
Time taken for tests:   9.043 seconds
Median response time:   158 ms
95% served within:      238 ms
```

Grafana also captured the test traffic:

```text
Product API Requests:       1000
Average Product API Latency: 148 ms
```

These numbers represent results from the local test environment and are not intended as general production capacity guarantees.

---

## CI Pipeline

GitHub Actions runs the CI workflow for pushes and pull requests targeting `main`.

The pipeline currently performs:

```text
Checkout Repository
        |
        v
Install Backend Dependencies
        |
        v
Python Syntax Check
        |
        v
Install Frontend Dependencies
        |
        v
Build React Frontend
        |
        v
Validate Docker Compose
        |
        v
Build Docker Images
```

The GitHub Actions CI workflow has been successfully executed.

---

## CD Status

Automated remote deployment is intentionally not enabled yet because the project currently runs in a local environment and no dedicated remote deployment server has been configured.

The existing Blue/Green deployment scripts are ready to be invoked from a future CD job once a deployment server and secure SSH-based deployment mechanism are available.

This distinction keeps the project documentation accurate: **CI is implemented, while remote CD remains a future deployment-stage integration.**

---

## Security Practices

The project currently includes several basic security practices:

- `.env` is excluded from Git.
- `.env.example` contains placeholder credentials.
- PostgreSQL is not published directly to the host.
- Redis is not published directly to the host.
- Backend containers are not directly host-exposed.
- Loki is kept internal to the Docker network.
- Critical application containers are not running in privileged mode.
- Application traffic enters through Nginx.

For a real internet-facing deployment, additional hardening such as TLS, firewall rules, secure production secrets, restricted monitoring access, and server-level security should be configured.

---

## Verification Commands

Application health:

```bash
curl http://localhost/api/health
```

Identify active backend:

```bash
curl http://localhost/api/instance
```

Check Blue/Green upstream:

```bash
grep "server backend-" nginx/default.conf
```

Check containers:

```bash
docker compose ps
```

Validate Nginx:

```bash
docker exec ecommerce-nginx nginx -t
```

---

## Project Results

This project successfully demonstrates:

- Multi-container application deployment
- React and FastAPI containerization
- PostgreSQL persistent storage
- Redis caching
- Nginx reverse proxy
- Blue/Green backend deployment
- Health-checked traffic switching
- Automated rollback
- Prometheus monitoring
- Grafana dashboards
- Loki centralized logging
- PostgreSQL backup and restore testing
- Nginx gzip compression
- Static asset caching
- API load testing
- GitHub Actions CI
- Basic container and secret-management security practices

---

## Future Improvements

Future production improvements can include:

- Remote CD deployment
- HTTPS/TLS
- Secure production secret management
- Restricted access to Grafana and Prometheus
- Automated Grafana provisioning
- More comprehensive automated backend tests
- Pinned container image versions
- Production server firewall configuration

---

## Author

**Ayesha**

DevOps Project — Production-Grade Multi-Container Deployment with Docker Compose, Monitoring and Blue/Green Deployment
