
#!/bin/bash

# PostgreSQL RDS credentials
DB_HOST="postgress db host ip/dns"
DB_USER="username"
DB_PASS='passwd'

# List of databases to back up
DB_NAMES=("db1" "db2" )

# Backup destination directory
BACKUP_DIR="/home/ubuntu/rds-postgres-db-backup"

# AWS S3 bucket details
S3_BUCKET="s3://repo location"
DATE=$(date +%F)

# Export PostgreSQL password for authentication
export PGPASSWORD=$DB_PASS

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Loop through each database and create a backup
for DB_NAME in "${DB_NAMES[@]}"; do
    BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.dump"

    echo "Creating backup for database: $DB_NAME..."

    # Create a dump file for the current database
    pg_dump -h $DB_HOST -U $DB_USER -Fc $DB_NAME > $BACKUP_FILE

    if [ $? -eq 0 ]; then
        echo "Backup created successfully for $DB_NAME: $BACKUP_FILE"

        # Upload to S3
        echo "Uploading $DB_NAME backup to S3..."
        aws s3 cp $BACKUP_FILE $S3_BUCKET/

        if [ $? -eq 0 ]; then
            echo "Backup uploaded to S3 successfully for $DB_NAME."
            # Remove the local backup file after uploading
            #rm -f $BACKUP_FILE
        else
            echo "Failed to upload $DB_NAME backup to S3."
        fi
    else
        echo "Failed to create backup for $DB_NAME."
    fi
done

