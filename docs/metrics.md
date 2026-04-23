# 📋 Metrics Overview

Complete reference of all T-SQL queries used in the dashboard. All queries use native DMVs and system catalog views — no custom tables or stored procedures required.

---

## 🔮 Overview

| Metric | SQL Query |
|--------|-----------|
| Database Name | `SELECT DB_NAME() AS [Database];` |
| SQL Server Version | `SELECT CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50)) AS [Version];` |
| SQL Server Edition | `SELECT CAST(SERVERPROPERTY('Edition') AS NVARCHAR(100)) AS [Edition];` |
| Server Name | `SELECT CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(100)) AS [Server];` |
| Batch Requests/sec | `SELECT cntr_value AS [Batch Req/s] FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec';` |
| Active Connections | `SELECT COUNT(session_id) AS [Connections] FROM sys.dm_exec_sessions WHERE is_user_process = 1;` |
| Uptime | `SELECT CAST(DATEDIFF(HOUR, sqlserver_start_time, GETDATE()) AS VARCHAR) + 'h' AS [Uptime] FROM sys.dm_os_sys_info;` |
| Online Databases | `SELECT COUNT(*) AS [Databases] FROM sys.databases WHERE state_desc = 'ONLINE';` |
| Start Time | `SELECT sqlserver_start_time AS [Started At] FROM sys.dm_os_sys_info;` |
| Health Score | `DECLARE @s FLOAT=100; DECLARE @ple INT=(SELECT cntr_value FROM sys.dm_os_performance_counters WHERE object_name LIKE '%Buffer Manager%' AND counter_name='Page life expectancy'); DECLARE @blk INT=(SELECT COUNT(*) FROM sys.dm_exec_requests WHERE blocking_session_id>0); DECLARE @mg INT=(SELECT COUNT(*) FROM sys.dm_exec_query_memory_grants WHERE grant_time IS NULL); DECLARE @ch FLOAT=(SELECT CAST(SUM(CASE WHEN usecounts>1 THEN 1 ELSE 0 END) AS FLOAT)/NULLIF(COUNT(*),0)*100 FROM sys.dm_exec_cached_plans WHERE objtype IN('Adhoc','Prepared')); IF @ple<300 SET @s=@s-25 ELSE IF @ple<600 SET @s=@s-10; IF @blk>0 SET @s=@s-(@blk*10); IF @mg>0 SET @s=@s-(@mg*15); IF @ch<80 SET @s=@s-15 ELSE IF @ch<90 SET @s=@s-5; IF @s<0 SET @s=0; SELECT CAST(@s AS INT) AS [Health];` |
| Key Performance Counters | `SELECT MAX(CASE WHEN counter_name='Transactions/sec' AND instance_name='_Total' THEN cntr_value END) AS [Txns/s], MAX(CASE WHEN counter_name='Page Splits/sec' THEN cntr_value END) AS [Page Splits/s], MAX(CASE WHEN counter_name='Full Scans/sec' THEN cntr_value END) AS [Full Scans/s], MAX(CASE WHEN counter_name='Lock Waits/sec' AND instance_name='_Total' THEN cntr_value END) AS [Lock Waits/s] FROM sys.dm_os_performance_counters;` |
| Active Sessions by Login | `SELECT TOP 12 login_name AS [Login], COUNT(session_id) AS [Sessions] FROM sys.dm_exec_sessions WHERE is_user_process = 1 GROUP BY login_name ORDER BY [Sessions] DESC;` |
| Connections by App | `SELECT TOP 8 ISNULL(NULLIF(program_name,''),'Unknown') AS [App], COUNT(*) AS [Sessions] FROM sys.dm_exec_sessions WHERE is_user_process=1 GROUP BY program_name ORDER BY COUNT(*) DESC;` |
| Network I/O by Client | `SELECT TOP 10 c.client_net_address AS [Client], CAST(SUM(c.num_reads)*8.0/1024 AS DECIMAL(10,2)) AS [Recv MB], CAST(SUM(c.num_writes)*8.0/1024 AS DECIMAL(10,2)) AS [Sent MB], COUNT(*) AS [Conn] FROM sys.dm_exec_connections c GROUP BY c.client_net_address ORDER BY SUM(c.num_reads+c.num_writes) DESC;` |
| Session Status | `SELECT status AS [Status], COUNT(*) AS [Count] FROM sys.dm_exec_sessions WHERE is_user_process=1 GROUP BY status ORDER BY COUNT(*) DESC;` |

---

## ⚡ Query Performance

| Metric | SQL Query |
|--------|-----------|
| Top 10 Slowest Queries | `SELECT TOP 10 LEFT(SUBSTRING(qt.text, qs.statement_start_offset/2+1, (CASE WHEN qs.statement_end_offset=-1 THEN LEN(CONVERT(NVARCHAR(MAX),qt.text))*2 ELSE qs.statement_end_offset END - qs.statement_start_offset)/2+1),80) AS [Query], CAST(qs.total_elapsed_time/qs.execution_count/1000.0 AS DECIMAL(18,2)) AS [Avg ms] FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt WHERE qs.execution_count > 0 ORDER BY qs.total_elapsed_time/qs.execution_count DESC;` |
| Top 10 CPU-Heavy Queries | `SELECT TOP 10 LEFT(st.text, 80) AS [Query], qs.total_worker_time AS [CPU µs] FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st ORDER BY qs.total_worker_time DESC;` |
| Top 10 I/O-Heavy Queries | `SELECT TOP 10 LEFT(st.text, 80) AS [Query], qs.total_logical_reads AS [Logical Reads] FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st ORDER BY qs.total_logical_reads DESC;` |
| Top 10 Most Executed | `SELECT TOP 10 LEFT(st.text, 80) AS [Query], qs.execution_count AS [Executions] FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st ORDER BY qs.execution_count DESC;` |
| Top 10 Physical Reads | `SELECT TOP 10 LEFT(st.text, 80) AS [Query], qs.total_physical_reads AS [Physical Reads] FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st WHERE qs.total_physical_reads > 0 ORDER BY qs.total_physical_reads DESC;` |
| Top 10 Write-Heavy | `SELECT TOP 10 LEFT(st.text, 80) AS [Query], qs.total_logical_writes AS [Logical Writes] FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st WHERE qs.total_logical_writes > 0 ORDER BY qs.total_logical_writes DESC;` |
| Compilation & Cache Stats | `SELECT MAX(CASE WHEN counter_name='SQL Compilations/sec' THEN cntr_value END) AS [Compilations/s], MAX(CASE WHEN counter_name='SQL Re-Compilations/sec' THEN cntr_value END) AS [Re-Compilations/s], CAST((CAST(SUM(CASE WHEN cp.usecounts>1 THEN 1 ELSE 0 END) AS FLOAT)/NULLIF(COUNT(cp.plan_handle),0))*100 AS DECIMAL(5,2)) AS [Cache Hit %] FROM sys.dm_os_performance_counters CROSS JOIN sys.dm_exec_cached_plans cp WHERE counter_name IN ('SQL Compilations/sec','SQL Re-Compilations/sec') AND cp.objtype IN ('Adhoc','Prepared') GROUP BY counter_name HAVING counter_name = 'SQL Compilations/sec';` |
| Plan Cache by Type | `SELECT objtype AS [Type], CAST(SUM(size_in_bytes)/1024.0/1024.0 AS DECIMAL(18,2)) AS [Size MB] FROM sys.dm_exec_cached_plans GROUP BY objtype ORDER BY [Size MB] DESC;` |
| Currently Running Requests | `SELECT TOP 15 r.session_id AS [SID], r.status AS [Status], r.total_elapsed_time AS [Elapsed ms], r.cpu_time AS [CPU ms], r.logical_reads AS [Reads], LEFT(st.text, 60) AS [Query] FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st WHERE r.session_id > 50 ORDER BY r.total_elapsed_time DESC;` |
| Cache Hit % | `SELECT CAST((CAST(SUM(CASE WHEN usecounts>1 THEN 1 ELSE 0 END) AS FLOAT)/NULLIF(COUNT(*),0))*100 AS DECIMAL(5,2)) AS [Cache Hit %] FROM sys.dm_exec_cached_plans WHERE objtype IN ('Adhoc','Prepared');` |
| Active Transactions | `SELECT COUNT(*) AS [Active Txns] FROM sys.dm_tran_active_transactions WHERE transaction_type != 4;` |

---

## 🖥 Server Performance & Waits

| Metric | SQL Query |
|--------|-----------|
| Top 15 Wait Types | `SELECT TOP 15 wait_type AS [Wait Type], wait_time_ms AS [Wait ms] FROM sys.dm_os_wait_stats WHERE wait_type NOT IN ('SLEEP_TASK','BROKER_TASK_STOP','SQLTRACE_BUFFER_FLUSH','CLR_AUTO_EVENT','CLR_MANUAL_EVENT','LAZYWRITER_SLEEP','RESOURCE_QUEUE','CHECKPOINT_QUEUE','REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_EVENTHANDLER','FT_IFTS_SCHEDULER_IDLE_WAIT','XE_DISPATCHER_WAIT','WAITFOR','HADR_FILESTREAM_IOMGR_IOCOMPLETION','DIRTY_PAGE_POLL','SP_SERVER_DIAGNOSTICS_SLEEP','ONDEMAND_TASK_QUEUE','DISPATCHER_QUEUE_SEMAPHORE','PREEMPTIVE_OS_AUTHENTICATIONOPS','BROKER_RECEIVE_WAITFOR','PREEMPTIVE_XE_GETTARGETSTATE') AND wait_time_ms > 0 ORDER BY wait_time_ms DESC;` |
| Lock Distribution | `SELECT request_mode AS [Lock], request_status AS [Status], COUNT(*) AS [Count] FROM sys.dm_tran_locks GROUP BY request_mode, request_status ORDER BY [Count] DESC;` |
| Signal vs Resource Waits | `SELECT SUM(signal_wait_time_ms) AS [Signal (CPU)], SUM(wait_time_ms - signal_wait_time_ms) AS [Resource (I/O)], CAST(SUM(signal_wait_time_ms)*100.0/NULLIF(SUM(wait_time_ms),0) AS DECIMAL(5,2)) AS [Signal %] FROM sys.dm_os_wait_stats WHERE wait_type NOT IN ('SLEEP_TASK','BROKER_TASK_STOP',...);` |
| Thread & I/O Status | `SELECT SUM(CASE WHEN status='running' THEN 1 ELSE 0 END) AS [Running], SUM(CASE WHEN status='sleeping' THEN 1 ELSE 0 END) AS [Sleeping], SUM(CASE WHEN blocking_session_id>0 THEN 1 ELSE 0 END) AS [Blocked], (SELECT COUNT(*) FROM sys.dm_io_pending_io_requests) AS [Pending I/O] FROM sys.dm_exec_requests WHERE session_id > 50;` |
| Active Blocking Chains | `SELECT r.session_id AS [Blocked SID], r.blocking_session_id AS [Blocker SID], r.wait_type AS [Wait Type], r.wait_time AS [Wait ms], LEFT(st.text, 80) AS [Blocked Query] FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st WHERE r.blocking_session_id > 0 ORDER BY r.wait_time DESC;` |
| Open Transactions | `SELECT TOP 10 s.session_id AS [SID], s.login_name AS [Login], t.name AS [Txn], DATEDIFF(SECOND, t.transaction_begin_time, GETDATE()) AS [Duration s], t.transaction_type AS [Type] FROM sys.dm_tran_active_transactions t JOIN sys.dm_tran_session_transactions st ON t.transaction_id=st.transaction_id JOIN sys.dm_exec_sessions s ON st.session_id=s.session_id WHERE t.transaction_type != 4 ORDER BY t.transaction_begin_time;` |
| TempDB Allocation | `SELECT SUM(user_objects_alloc_page_count)*8/1024 AS [User Objects MB], SUM(internal_objects_alloc_page_count)*8/1024 AS [Internal Objects MB] FROM sys.dm_db_session_space_usage;` |
| I/O Stall per DB File | `SELECT DB_NAME(vfs.database_id) + ' [' + mf.name + ']' AS [DB File], vfs.io_stall_read_ms AS [Read Stall ms], vfs.io_stall_write_ms AS [Write Stall ms] FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs JOIN sys.master_files mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id WHERE vfs.database_id > 4 ORDER BY (vfs.io_stall_read_ms + vfs.io_stall_write_ms) DESC;` |
| Scheduler Health | `SELECT scheduler_id AS [Scheduler], current_tasks_count AS [Current Tasks], runnable_tasks_count AS [Runnable], active_workers_count AS [Active Workers], work_queue_count AS [Queued] FROM sys.dm_os_schedulers WHERE status = 'VISIBLE ONLINE' ORDER BY scheduler_id;` |

---

## 🧠 Memory & Buffer

| Metric | SQL Query |
|--------|-----------|
| Page Life Expectancy | `SELECT cntr_value AS [PLE (s)] FROM sys.dm_os_performance_counters WHERE object_name LIKE '%Buffer Manager%' AND counter_name = 'Page life expectancy';` |
| Memory Grants Pending | `SELECT COUNT(*) AS [Pending Grants] FROM sys.dm_exec_query_memory_grants WHERE grant_time IS NULL;` |
| Buffer Pool Breakdown | `SELECT CAST(COUNT(*)*8.0/1024 AS DECIMAL(10,2)) AS [Buffer Pool MB], CAST(SUM(CASE WHEN is_modified=1 THEN 1 ELSE 0 END)*8.0/1024 AS DECIMAL(10,2)) AS [Dirty Pages MB], CAST(SUM(CASE WHEN is_modified=0 THEN 1 ELSE 0 END)*8.0/1024 AS DECIMAL(10,2)) AS [Clean Pages MB] FROM sys.dm_os_buffer_descriptors WHERE database_id > 4;` |
| Memory Overview | `SELECT MAX(CASE WHEN counter_name='Total Server Memory (KB)' THEN cntr_value/1024 END) AS [Total Server MB], MAX(CASE WHEN counter_name='Target Server Memory (KB)' THEN cntr_value/1024 END) AS [Target Server MB], (SELECT available_physical_memory_kb/1024 FROM sys.dm_os_sys_memory) AS [Available MB], (SELECT (total_physical_memory_kb-available_physical_memory_kb)/1024 FROM sys.dm_os_sys_memory) AS [Used MB] FROM sys.dm_os_performance_counters WHERE counter_name IN('Total Server Memory (KB)','Target Server Memory (KB)');` |
| Top Memory Clerks | `SELECT TOP 10 type AS [Memory Clerk], CAST(SUM(pages_kb)/1024.0 AS DECIMAL(18,2)) AS [Size MB] FROM sys.dm_os_memory_clerks GROUP BY type ORDER BY SUM(pages_kb) DESC;` |
| Buffer per Database | `SELECT CASE WHEN database_id=32767 THEN 'ResourceDB' ELSE DB_NAME(database_id) END AS [Database], CAST(COUNT(*)*8.0/1024 AS DECIMAL(10,2)) AS [Buffer MB] FROM sys.dm_os_buffer_descriptors GROUP BY database_id ORDER BY COUNT(*) DESC;` |
| Index Usage | `SELECT TOP 10 OBJECT_NAME(s.object_id) AS [Table], s.user_seeks AS [Seeks], s.user_scans AS [Scans], s.user_lookups AS [Lookups], s.user_updates AS [Updates] FROM sys.dm_db_index_usage_stats s JOIN sys.indexes i ON i.object_id=s.object_id AND i.index_id=s.index_id WHERE s.database_id=DB_ID() AND OBJECTPROPERTY(s.object_id,'IsUserTable')=1 ORDER BY (s.user_seeks+s.user_scans+s.user_lookups) DESC;` |

---

## 🔄 Index Health

| Metric | SQL Query |
|--------|-----------|
| Index Fragmentation | `SELECT TOP 20 OBJECT_NAME(ips.object_id) AS [Table], i.name AS [Index], CAST(ips.avg_fragmentation_in_percent AS DECIMAL(5,1)) AS [Frag %], ips.page_count AS [Pages], CASE WHEN ips.avg_fragmentation_in_percent > 30 THEN 'REBUILD' WHEN ips.avg_fragmentation_in_percent > 10 THEN 'REORGANIZE' ELSE 'OK' END AS [Action] FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'LIMITED') ips JOIN sys.indexes i ON ips.object_id=i.object_id AND ips.index_id=i.index_id WHERE ips.avg_fragmentation_in_percent > 5 AND ips.page_count > 50 AND i.name IS NOT NULL ORDER BY ips.avg_fragmentation_in_percent DESC;` |
| Unused Indexes | `SELECT TOP 15 OBJECT_NAME(s.object_id) AS [Table], i.name AS [Index], s.user_updates AS [Updates], CAST(SUM(a.total_pages)*8.0/1024 AS DECIMAL(10,2)) AS [Size MB] FROM sys.dm_db_index_usage_stats s JOIN sys.indexes i ON s.object_id=i.object_id AND s.index_id=i.index_id JOIN sys.partitions p ON i.object_id=p.object_id AND i.index_id=p.index_id JOIN sys.allocation_units a ON p.partition_id=a.container_id WHERE s.database_id=DB_ID() AND OBJECTPROPERTY(s.object_id,'IsUserTable')=1 AND s.user_seeks=0 AND s.user_scans=0 AND s.user_lookups=0 AND s.user_updates > 0 AND i.index_id > 1 GROUP BY OBJECT_NAME(s.object_id), i.name, s.user_updates ORDER BY s.user_updates DESC;` |

---

## 💿 Database Space

| Metric | SQL Query |
|--------|-----------|
| Database Sizes | `SELECT DB_NAME(database_id) AS [Database], CAST(SUM(size)*8.0/1024 AS DECIMAL(18,2)) AS [Total MB] FROM sys.master_files WHERE database_id > 4 GROUP BY database_id ORDER BY [Total MB] DESC;` |
| Transaction Log Space | `DBCC SQLPERF(LOGSPACE);` |
| File Distribution | `SELECT name AS [File], CAST(size*8.0/1024 AS DECIMAL(18,2)) AS [Size MB] FROM sys.master_files WHERE database_id > 4 ORDER BY size DESC;` |
| Top Tables by Size | `SELECT TOP 15 t.name AS [Table], CAST(SUM(a.total_pages)*8.0/1024 AS DECIMAL(18,2)) AS [Size MB] FROM sys.tables t JOIN sys.indexes i ON t.object_id=i.object_id JOIN sys.partitions p ON i.object_id=p.object_id AND i.index_id=p.index_id JOIN sys.allocation_units a ON p.partition_id=a.container_id GROUP BY t.name ORDER BY SUM(a.total_pages) DESC;` |
| Backup History | `SELECT TOP 20 database_name AS [Database], backup_start_date AS [Start], backup_finish_date AS [Finish], CAST(backup_size/1024.0/1024.0 AS DECIMAL(18,2)) AS [Size MB] FROM msdb.dbo.backupset ORDER BY backup_start_date DESC;` |
| Data Overview | `SELECT (SELECT COUNT(*) FROM sys.tables) AS [Tables], (SELECT SUM(p.rows) FROM sys.tables t JOIN sys.partitions p ON t.object_id=p.object_id WHERE p.index_id IN (0,1)) AS [Total Rows], (SELECT COUNT(*) FROM sys.dm_db_missing_index_details WHERE database_id=DB_ID()) AS [Missing Indexes];` |
| Missing Index Suggestions | `SELECT TOP 10 OBJECT_NAME(d.object_id, d.database_id) AS [Table], d.equality_columns AS [Eq Cols], d.inequality_columns AS [Ineq], d.included_columns AS [Include], CAST(s.avg_user_impact AS INT) AS [Impact] FROM sys.dm_db_missing_index_details d JOIN sys.dm_db_missing_index_groups g ON d.index_handle=g.index_handle JOIN sys.dm_db_missing_index_group_stats s ON g.index_group_handle=s.group_handle WHERE d.database_id = DB_ID() ORDER BY s.avg_user_impact DESC;` |

---

## 🔒 Security & Errors

| Metric | SQL Query |
|--------|-----------|
| Security Counters | `SELECT MAX(CASE WHEN counter_name='Logins/sec' THEN cntr_value END) AS [Logins], MAX(CASE WHEN counter_name='Logouts/sec' THEN cntr_value END) AS [Logouts], (SELECT cntr_value FROM sys.dm_os_performance_counters WHERE counter_name='Number of Deadlocks/sec' AND instance_name='_Total') AS [Deadlocks], (SELECT cntr_value FROM sys.dm_os_performance_counters WHERE counter_name='Errors/sec' AND instance_name='_Total') AS [Errors/s] FROM sys.dm_os_performance_counters WHERE counter_name IN ('Logins/sec','Logouts/sec');` |
| Sysadmin Members | `SELECT p.name AS [Login], p.type_desc AS [Type] FROM sys.server_principals p JOIN sys.server_role_members rm ON p.principal_id=rm.member_principal_id JOIN sys.server_principals r ON rm.role_principal_id=r.principal_id WHERE r.name='sysadmin' AND p.is_disabled=0 ORDER BY p.name;` |
| Database States | `SELECT name AS [Database], state_desc AS [State], recovery_model_desc AS [Recovery], compatibility_level AS [Compat], collation_name AS [Collation] FROM sys.databases ORDER BY name;` |

---

## ⏰ Jobs Monitoring

| Metric | SQL Query |
|--------|-----------|
| Job Frequency (7d) | `SELECT j.name AS [Job], COUNT(*) AS [Runs] FROM msdb.dbo.sysjobs j JOIN msdb.dbo.sysjobhistory h ON j.job_id=h.job_id WHERE h.run_date >= CONVERT(VARCHAR,GETDATE()-7,112) AND h.step_id=0 GROUP BY j.name ORDER BY [Runs] DESC;` |
| Running Jobs | `SELECT DISTINCT j.name AS [Job], a.run_requested_date AS [Started], DATEDIFF(SECOND,a.run_requested_date,GETDATE()) AS [Duration (s)] FROM msdb.dbo.sysjobs j JOIN msdb.dbo.sysjobactivity a ON j.job_id=a.job_id WHERE a.run_requested_date IS NOT NULL AND a.stop_execution_date IS NULL ORDER BY a.run_requested_date DESC;` |
| Scheduled Jobs | `SELECT TOP 20 j.name AS [Job], CASE WHEN a.run_requested_date IS NOT NULL AND a.stop_execution_date IS NULL THEN 'Running' ELSE 'Scheduled' END AS [Status], s.next_run_date AS [Next Run], s.next_run_time AS [Time] FROM msdb.dbo.sysjobs j LEFT JOIN msdb.dbo.sysjobactivity a ON j.job_id=a.job_id LEFT JOIN msdb.dbo.sysjobschedules s ON j.job_id=s.job_id WHERE (a.stop_execution_date IS NULL AND a.run_requested_date IS NOT NULL) OR s.next_run_date>0 ORDER BY s.next_run_date, s.next_run_time;` |
| Job History | `SELECT TOP 30 j.name AS [Job], h.run_date AS [Date], h.run_duration AS [Duration] FROM msdb.dbo.sysjobs j JOIN msdb.dbo.sysjobhistory h ON j.job_id=h.job_id WHERE h.step_id=0 ORDER BY h.run_date DESC, h.run_time DESC;` |
| Failed Jobs | `SELECT TOP 20 j.name AS [Job], h.run_date AS [Date], h.run_time AS [Time], LEFT(h.message,150) AS [Error] FROM msdb.dbo.sysjobs j JOIN msdb.dbo.sysjobhistory h ON j.job_id=h.job_id WHERE h.run_status=0 ORDER BY h.run_date DESC, h.run_time DESC;` |

---

## 📊 DMV Reference

All queries in this dashboard use the following SQL Server Dynamic Management Views and system objects:

| Category | DMVs / Objects |
|----------|---------------|
| **Execution** | `sys.dm_exec_query_stats`, `sys.dm_exec_sql_text`, `sys.dm_exec_cached_plans`, `sys.dm_exec_requests`, `sys.dm_exec_sessions`, `sys.dm_exec_connections`, `sys.dm_exec_query_memory_grants` |
| **OS** | `sys.dm_os_sys_info`, `sys.dm_os_performance_counters`, `sys.dm_os_wait_stats`, `sys.dm_os_schedulers`, `sys.dm_os_sys_memory`, `sys.dm_os_memory_clerks`, `sys.dm_os_buffer_descriptors` |
| **I/O** | `sys.dm_io_virtual_file_stats`, `sys.dm_io_pending_io_requests` |
| **Transactions** | `sys.dm_tran_locks`, `sys.dm_tran_active_transactions`, `sys.dm_tran_session_transactions` |
| **Indexes** | `sys.dm_db_index_usage_stats`, `sys.dm_db_index_physical_stats`, `sys.dm_db_missing_index_details`, `sys.dm_db_missing_index_groups`, `sys.dm_db_missing_index_group_stats` |
| **TempDB** | `sys.dm_db_session_space_usage` |
| **Catalog** | `sys.databases`, `sys.tables`, `sys.indexes`, `sys.partitions`, `sys.allocation_units`, `sys.master_files`, `sys.server_principals`, `sys.server_role_members` |
| **MSDB** | `msdb.dbo.backupset`, `msdb.dbo.sysjobs`, `msdb.dbo.sysjobhistory`, `msdb.dbo.sysjobactivity`, `msdb.dbo.sysjobschedules` |
| **Functions** | `SERVERPROPERTY()`, `DB_NAME()`, `DB_ID()`, `OBJECT_NAME()`, `DBCC SQLPERF()` |
