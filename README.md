<p align="center">
	<a href="https://twitter.com/cz_antoine"><img alt="Twitter" src="https://img.shields.io/twitter/follow/cz_antoine?style=social"></a>
	<a href="https://www.linkedin.com/in/antoine-cichowicz-837575b1"><img alt="Linkedin" src="https://img.shields.io/badge/-Antoine-blue?style=flat-square&logo=Linkedin&logoColor=white"></a>
	<a href="https://github.com/czantoine/microsoft-sql-server-with-grafana"><img alt="Stars" src="https://img.shields.io/github/stars/czantoine/microsoft-sql-server-with-grafana"></a>
	<a href="https://github.com/czantoine/microsoft-sql-server-with-grafana"><img alt="Issues" src="https://img.shields.io/github/issues/czantoine/microsoft-sql-server-with-grafana"></a>
	<img alt="Last Commit" src="https://img.shields.io/github/last-commit/czantoine/microsoft-sql-server-with-grafana">
</p>

# Monitoring Microsoft SQL Server with Grafana

<a href="https://grafana.com/dashboards/21378">
    <img src="https://grafana-dashboard-badge.netlify.app/.netlify/functions/api/badge?id_dashboard=21378&logo=true" alt="Grafana Dashboard Badge">
</a>

Example of the metrics you should expect to retrieve; the detailed list of exported metrics is maintained [here](docs/metrics.md).

A Docker Compose setup is available if you wish to test the dashboard. Available [here](quickstart/README.md).

## Features

This is a comprehensive Grafana dashboard designed for monitoring Microsoft SQL Server. It provides real-time insights into your SQL Server environment, making it easy for both technical and non-technical users to understand the performance of their SQL Server instances.

## Data Source Setup
The data source for this dashboard can directly be your SQL Server database instance. Ensure that the SQL Server instance is accessible to Grafana.

### General
- **Database name**: Displays the database name.
- **Uptime**: Displays the SQL Server start time.
- **Active User Sessions**: Shows the count of active user sessions by login name.

![grafana_dashboard_microsoft_sql_server_section_general](docs/images/grafana_dashboard_microsoft_sql_server_section_general.png)

### Query Performance
- **Top 10 Longest Running Queries**: Lists the top 10 queries with the longest average duration.
- **Queries per Second**: Provides average duration and execution count of queries.
- **Query Cache Hit Rate**: Visualizes the cache hit ratio for queries.
- **Query Plan Cache Efficiency**: Shows the efficiency of cached query plans.
- **Wait Stats Overview**: Displays an overview of wait statistics in SQL Server.
- **Current Connections**: Indicates the current number of connections to the SQL Server.
- **Query Latency**: Visualizes latency for recent queries.
- **Execution Plans Performance**: Monitors performance metrics of executed plans.

![grafana_dashboard_microsoft_sql_server_section_query_performance](docs/images/grafana_dashboard_microsoft_sql_server_section_query_performance.png)

### Server Performance
- **Query Latency**: Displays the top 10 longest running queries based on total elapsed time.
- **Running Threads**: Displays the number of running threads in the SQL Server.
- **Open Files Limit**: Shows the count of currently open files.
- **Active Transactions**: Provides details on active transactions in the system.
- **Temp Tables Created On Disk**: Monitors the number of temporary tables created on disk.
- **Table Locks**: Displays information on current table locks.
- **Waiting Times Monitoring**: Provides an overview of wait statistics in SQL Server.

![grafana_dashboard_microsoft_sql_server_section_server_performance](docs/images/grafana_dashboard_microsoft_sql_server_section_server_performance.png)

### Buffer and Index Management
- **Buffer Pool Hit Rate**: Visualizes the hit rate of the buffer pool.
- **Buffer Pool Usage**: Monitors the overall usage of the buffer pool.
- **Index Usage**: Displays usage statistics for database indexes.
- **Page Life Expectancy**: Shows the average time pages stay in the buffer pool.

![grafana_dashboard_microsoft_sql_server_section_buffer_and_index_management](docs/images/grafana_dashboard_microsoft_sql_server_section_buffer_and_index_management.png)

### Database Space Usage
- **Total Space**: Displays the total space allocated to all tables in the database.
- **Used Space**: Shows the space currently used by all tables.
- **Unused Space**: Provides information on unused space in the database.
- **Memory Grants Pending**: Indicates the count of pending memory grants.
- **Transaction Log Space Usage**: Displays the usage of transaction log space.
- **Database File Usage**: Shows details about database files and their sizes.
- **Table Locks**: Provides information on current table locks.
- **Backups Status**: Displays the status of recent database backups.
- **Memory Usage**: Visualizes overall memory usage in SQL Server.
- **TempDB Disk Monitoring**: Monitors I/O stalls for TempDB files.
- 
![grafana_dashboard_microsoft_sql_server_section_database_space_usage](docs/images/grafana_dashboard_microsoft_sql_server_section_database_space_usage.png)

### Jobs Monitoring
- **Job Execution Frequency**: Displays the execution count of jobs over the last week.
- **Job Execution History Duration**: Shows job execution history along with durations.
- **Jobs in Progress**: Lists jobs that are currently running along with their durations.
- **Failed Jobs Overview**: Provides an overview of recently failed jobs and their error messages.
- **Scheduled and Running Jobs**: Displays the status of scheduled and currently running jobs.

![grafana_dashboard_microsoft_sql_server_section_jobs_monitoring](docs/images/grafana_dashboard_microsoft_sql_server_section_jobs_monitoring.png)

You can directly find the [dashboard here](https://grafana.com/grafana/dashboards/21378-microsoft-sql-server-dashboard/) or use the ID: 21378.

--- 

If you find this project useful, please give it a star ⭐️ ! Your support is greatly appreciated. Also, feel free to contribute to this project. All contributions, whether bug fixes, improvements, or new features, are welcome!
