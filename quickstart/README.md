# Example usage of Monitoring with Grafana and Microsoft SQL Server

[![grafana-microsoft-sql-server-dashboard-docker](https://github.com/czantoine/microsoft-sql-server-with-grafana/actions/workflows/grafana-microsoft-sql-server-dashboard.yml/badge.svg)](https://github.com/czantoine/microsoft-sql-server-with-grafana/actions/workflows/grafana-microsoft-sql-server-dashboard.yml)
[![mssql-demo-docker](https://github.com/czantoine/microsoft-sql-server-with-grafana/actions/workflows/mssql-demo.yml/badge.svg)](https://github.com/czantoine/microsoft-sql-server-with-grafana/actions/workflows/mssql-demo.yml)

# Requirements

- **~2 min of your time**
- [git](https://git-scm.com/) & [docker-compose](https://docs.docker.com/compose/)

## Deploy

``` bash
# Clone this repository
git clone https://github.com/czantoine/microsoft-sql-server-with-grafana
cd microsoft-sql-server-with-grafana/quickstart

# Start Grafana and SQL Server containers !
docker-compose up -d
```

You should now have a stack completely configured and accessible at these locations:

It might take up to **1 minute** for the database to initialize and for metrics to start appearing in Grafana. During this time, the dashboard may not show any data.

- `grafana-microsoft-sql-server-dashboard`: [http://localhost:3009](http://localhost:3009) (if you want/need to login, creds are `admin/admin_password`)
- `mssql-demo`: localhost:1433 (if you want/need to login, creds are `sa/YourStrong@Passw0rd`)

There are currently **no data available for the Jobs Monitoring** section of the dashboard.

## Use and troubleshoot

### Validate that containers are running

```bash
docker ps
CONTAINER ID   IMAGE                                    COMMAND          CREATED         STATUS         PORTS                    NAMES
d14c99a109c9   grafana-microsoft-sql-server-dashboard   "/run.sh"        3 minutes ago   Up 3 minutes   0.0.0.0:3009->3000/tcp   grafana
d50232cb287f   mssql-demo                               "./init-db.sh"   3 minutes ago   Up 3 minutes   0.0.0.0:1433->1433/tcp   sqlserver-demo
```

### Checkout the grafana example dashboards

Example dashboards should be available at these addresses:

- **Monitoring dashboard** - [http://localhost:3009/d/microsoft-sql-server-dashboard](http://localhost:3009/d/bff36b75-3eae-44b8-994b-c7a87274d162/microsoft-sql-server-dashboard)

![grafana_dashboard_microsoft_sql_server_example](/docs/images/grafana_dashboard_microsoft_sql_server_example.png)

## Cleanup

```bash
docker-compose down
```