# 🚀 Quickstart — SQL Server Monitoring with Grafana

<p align="center">
  <a href="https://github.com/czantoine/microsoft-sql-server-with-grafana/actions/workflows/grafana-microsoft-sql-server-dashboard.yml"><img src="https://github.com/czantoine/microsoft-sql-server-with-grafana/actions/workflows/grafana-microsoft-sql-server-dashboard.yml/badge.svg" alt="Grafana Docker"></a>
  <a href="https://github.com/czantoine/microsoft-sql-server-with-grafana/actions/workflows/mssql-demo.yml"><img src="https://github.com/czantoine/microsoft-sql-server-with-grafana/actions/workflows/mssql-demo.yml/badge.svg" alt="MSSQL Docker"></a>
</p>

> Get a fully working SQL Server + Grafana monitoring stack in **under 2 minutes**. No configuration needed.

---

## 📋 Requirements

| Requirement | Version |
|-------------|---------|
| [Git](https://git-scm.com/) | Any |
| [Docker](https://docs.docker.com/get-docker/) | 20.10+ |
| [Docker Compose](https://docs.docker.com/compose/) | v2+ |
| Free RAM | ~2 GB (SQL Server minimum) |

---

## ⚡ Deploy

```bash
# Clone the repository
git clone https://github.com/czantoine/microsoft-sql-server-with-grafana
cd microsoft-sql-server-with-grafana/quickstart

# Start the stack
docker compose up -d
```

That's it! Both containers will start, the database will initialize automatically with demo data, and Grafana will be pre-configured with the dashboard.

---

## 🔗 Access

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | [http://localhost:3009](http://localhost:3009) | `admin` / `admin_password` |
| **SQL Server** | `localhost:1433` | `sa` / `YourStrong@Passw0rd` |

> **⏳ Note**: It may take up to **60 seconds** for the database to fully initialize. During this time, some panels may show "No data". Simply wait and refresh.

---

## 🏗 What's Inside

### Architecture

```
┌─────────────────────────┐       T-SQL (port 1433)       ┌──────────────────────┐
│  grafana                │ ─────────────────────────────> │  sqlserver-demo      │
│                         │ <───────────────────────────── │                      │
│  • Pre-configured       │       Result Sets              │  • SQL Server 2022   │
│  • Dashboard imported   │                                │  • DemoDB created    │
│  • MSSQL datasource     │                                │  • Continuous data   │
│  • Port 3009            │                                │  • Auto backups      │
│                         │                                │  • Port 1433         │
└─────────────────────────┘                                └──────────────────────┘
```

### SQL Server Container (`mssql-demo`)

The SQL Server container automatically:

1. **Starts** SQL Server 2022 Developer Edition
2. **Creates** the `DemoDB` database with tables: `Customers`, `Products`, `Orders`, `OrderItems`, `AuditLog`
3. **Seeds** initial data (15 customers, 20 products)
4. **Inserts** new data every 20 seconds (customers, orders, audit logs)
5. **Generates** realistic query activity (cross joins, aggregations, full scans)
6. **Runs** 2 automatic backups (at ~2min and ~5min) visible in the Backup History panel

### Grafana Container (`grafana-microsoft-sql-server-dashboard`)

Pre-configured with:

- **MSSQL data source** pointing to the SQL Server container
- **60+ panel dashboard** auto-imported and set as home
- **Auto-refresh** every 30 seconds

---

## 📊 Dashboard Preview

Once running, navigate to the dashboard:

**[http://localhost:3009/d/bff36b75-3eae-44b8-994b-c7a87274d162/microsoft-sql-server-dashboard](http://localhost:3009/d/bff36b75-3eae-44b8-994b-c7a87274d162/microsoft-sql-server-dashboard)**

![grafana_dashboard_microsoft_sql_server_example](/docs/images/grafana_dashboard_microsoft_sql_server_section_general.png)

### What You'll See

| Section | Panels | Highlights |
|---------|--------|------------|
| 🔮 Overview | 16 | Health Score gauge, version info, key counters, connections by app |
| ⚡ Query Performance | 11 | Top 10 slowest/CPU/I/O/executed/physical reads/writes queries |
| 🖥 Server Performance | 9 | Wait types, locks, blocking chains, signal vs resource waits |
| 🧠 Memory & Buffer | 7 | PLE, buffer pool, memory clerks, memory overview |
| 🔄 Index Health | 2 | Fragmentation with rebuild/reorganize recommendations, unused indexes |
| 💿 Database Space | 7 | DB sizes, log space, table sizes, backup history, missing indexes |
| 🔒 Security & Errors | 3 | Login activity, deadlocks, sysadmin audit, database states |
| ⏰ Jobs Monitoring | 5 | Job frequency, running/scheduled/failed jobs |

> **Note**: The **Jobs Monitoring** section requires SQL Server Agent, which is not available in the Docker container. These panels will show "No data" in this quickstart environment — they work on production SQL Server instances with Agent enabled.

---

## 🔧 Troubleshooting

### Verify containers are running

```bash
docker ps
```

Expected output:

```
CONTAINER ID   IMAGE                                    COMMAND          STATUS         PORTS                    NAMES
d14c99a109c9   grafana-microsoft-sql-server-dashboard   "/run.sh"        Up 3 minutes   0.0.0.0:3009->3000/tcp   grafana
d50232cb287f   mssql-demo                               "./init-db.sh"   Up 3 minutes   0.0.0.0:1433->1433/tcp   sqlserver-demo
```

### Port conflicts

If ports `3009` or `1433` are already in use:

```bash
# Edit docker-compose.yml and change the port mappings
# Example: change 3009:3000 to 3010:3000
# Example: change 1433:1433 to 1434:1433
```

---

## 🧹 Cleanup

```bash
# Stop and remove containers
docker compose down

# Also remove volumes (full cleanup)
docker compose down -v
```

---

## 🏠 Back to Main

See the [main README](../README.md) for the complete dashboard documentation, all metrics, and production deployment guide.