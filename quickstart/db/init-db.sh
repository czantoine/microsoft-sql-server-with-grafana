#!/bin/bash

# ============================================================
# SQL Server Docker Entrypoint
# - Installs ODBC/tools
# - Starts SQL Server
# - Creates DB + inserts data
# - Runs 2 automatic backups for Grafana demo
# ============================================================

# ----------------------------
# 1. Install dependencies
# ----------------------------
apt-get update
apt-get install -y curl
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update
ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

SQLCMD="/opt/mssql-tools/bin/sqlcmd"

# ----------------------------
# 2. Start SQL Server in background
# ----------------------------
/opt/mssql/bin/sqlservr &
SQLPID=$!

echo "⏳ Waiting for SQL Server to start..."
sleep 30

# ----------------------------
# 3. Verify SQL Server is ready
# ----------------------------
for i in {1..30}; do
    $SQLCMD -S localhost -U SA -P "$SA_PASSWORD" -Q "SELECT 1" -b > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ SQL Server is ready."
        break
    fi
    echo "⏳ Attempt $i/30 — waiting..."
    sleep 2
done

# ----------------------------
# 4. Create database & schema
# ----------------------------
echo "🔧 Creating database..."
$SQLCMD -S localhost -U SA -P "$SA_PASSWORD" -d master -i /tmp/create_db.sql

if [ $? -ne 0 ]; then
    echo "❌ Failed to create database. Exiting."
    exit 1
fi
echo "✅ Database created."

# ----------------------------
# 5. Create backup directory
# ----------------------------
BACKUP_DIR="/var/opt/mssql/backup"
mkdir -p "$BACKUP_DIR"
chown -R 10001:0 "$BACKUP_DIR" 2>/dev/null || true
echo "📁 Backup directory ready: $BACKUP_DIR"

# ----------------------------
# 6. Background: scheduled backups
# ----------------------------
(
    # --- Backup #1 after ~2 minutes ---
    echo "⏳ Backup #1 scheduled in 120 seconds..."
    sleep 120

    TIMESTAMP1=$(date +%Y%m%d_%H%M%S)
    echo "💾 Running Backup #1 at $(date)..."

    $SQLCMD -S localhost -U SA -P "$SA_PASSWORD" -Q "
    BACKUP DATABASE [DemoDB]
    TO DISK = N'${BACKUP_DIR}/DemoDB_backup_${TIMESTAMP1}.bak'
    WITH FORMAT,
         MEDIANAME = 'DemoDBBackup',
         NAME = 'DemoDB Full Backup 1 - Demo',
         COMPRESSION,
         STATS = 10;
    "

    if [ $? -eq 0 ]; then
        echo "✅ Backup #1 completed: DemoDB_backup_${TIMESTAMP1}.bak"
    else
        echo "⚠️  Backup #1 failed!"
    fi

    # --- Backup #2 after ~3 more minutes (5 min total) ---
    echo "⏳ Backup #2 scheduled in 180 seconds..."
    sleep 180

    TIMESTAMP2=$(date +%Y%m%d_%H%M%S)
    echo "💾 Running Backup #2 at $(date)..."

    $SQLCMD -S localhost -U SA -P "$SA_PASSWORD" -Q "
    BACKUP DATABASE [DemoDB]
    TO DISK = N'${BACKUP_DIR}/DemoDB_backup_${TIMESTAMP2}.bak'
    WITH FORMAT,
         MEDIANAME = 'DemoDBBackup',
         NAME = 'DemoDB Full Backup 2 - Demo',
         COMPRESSION,
         STATS = 10;
    "

    if [ $? -eq 0 ]; then
        echo "✅ Backup #2 completed: DemoDB_backup_${TIMESTAMP2}.bak"
    else
        echo "⚠️  Backup #2 failed!"
    fi

    echo ""
    echo "📋 All backups in ${BACKUP_DIR}:"
    ls -lh ${BACKUP_DIR}/*.bak 2>/dev/null
    echo ""
    echo "🎉 Demo backups complete — visible in Grafana Backup History panel."

) &
BACKUP_PID=$!

# ----------------------------
# 7. Main loop: continuous data insert
# ----------------------------
echo "🔄 Starting continuous data inserts (every 20s)..."

while true; do
    $SQLCMD -S localhost -U SA -P "$SA_PASSWORD" -d DemoDB -i /tmp/insert_data.sql > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo "⚠️  Insert failed at $(date), retrying..."
    fi

    sleep 20
done

# ----------------------------
# 8. Keep container alive
# ----------------------------
wait $SQLPID