#!/bin/bash

# EXAMPLE OF HOW TO USE IT
# bash backup.sh --filename="file" --source_host="my_host" --source_database="db" --source_user="user" --source_password="123"  --destination_host="host" --destination_database="db" --destination_user="user" --destination_password="123" --force
# use the flag --force if you are sure on deleting & re-creating the target database

# read the options
SOURCE_DB="filename::,source_host::,source_database::,source_user::,source_password::,"
DEST_DB="destination_host::,destination_database::,destination_user::,destination_password::,force::"
TEMP=`getopt -o a:: --long ${SOURCE_DB}${DEST_DB} -n 'test.sh' -- "$@"`
eval set -- "$TEMP"

# extract all bash arguments into variables.
while true ; do
    case "$1" in
        --filename)
            case "$2" in
                "") filename='backup' ; shift 2 ;;
                *) filename=$2 ; shift 2 ;;
            esac ;;
        --source_host)
            case "$2" in
                "") source_host='' ; shift 2 ;;
                *) source_host=$2 ; shift 2 ;;
            esac ;;
        --source_database)
            case "$2" in
                "") source_database='' ; shift 2 ;;
                *) source_database=$2 ; shift 2 ;;
            esac ;;
        --source_user)
            case "$2" in
                "") source_user='' ; shift 2 ;;
                *) source_user=$2 ; shift 2 ;;
            esac ;;
        --source_password)
            case "$2" in
                "") source_password='' ; shift 2 ;;
                *) source_password=$2 ; shift 2 ;;
            esac ;;
        --destination_host)
            case "$2" in
                "") destination_host='' ; shift 2 ;;
                *) destination_host=$2 ; shift 2 ;;
            esac ;;
        --destination_database)
            case "$2" in
                "") destination_database='' ; shift 2 ;;
                *) destination_database=$2 ; shift 2 ;;
            esac ;;
        --destination_user)
            case "$2" in
                "") destination_user='' ; shift 2 ;;
                *) destination_user=$2 ; shift 2 ;;
            esac ;;
        --destination_password)
            case "$2" in
                "") destination_password='' ; shift 2 ;;
                *) destination_password=$2 ; shift 2 ;;
            esac ;;
        --force)
            case "$2" in
                "") force='true' ; shift 2 ;;
                *) force='true' ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

# backup database
echo "Step 1/6 - backup of the database ${source_database}."
pg_dump --dbname=postgresql://${source_user}:${source_password}@${source_host}:5432/${source_database} -v --no-owner -x --no-comments -f ${filename}.sql
echo "Step 2/6 - backup completed."

# check if the user wants to drop & re-create the destination database
if [[ $force != 'true' ]]
then
  read -p "The next command will drop & re-create the database ${destination_database}. Are you sure? Y/N" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # drop && create destination db
        echo "Step 3/6 - drop database ${destination_database}."
        psql --dbname=postgresql://${destination_user}:${destination_password}@${destination_host}:5432 -c "DROP DATABASE ${destination_database} WITH (FORCE);"
        echo "Step 4/6 - re-create database ${destination_database}."
        psql --dbname=postgresql://${destination_user}:${destination_password}@${destination_host}:5432 -c "CREATE DATABASE ${destination_database};"
    else
      exit 1
    fi
else
  echo "Step 3/6 - drop database ${destination_database}."
  psql --dbname=postgresql://${destination_user}:${destination_password}@${destination_host}:5432 -c "DROP DATABASE ${destination_database} WITH (FORCE);"
  echo "Step 4/6 - re-create database ${destination_database}."
  psql --dbname=postgresql://${destination_user}:${destination_password}@${destination_host}:5432 -c "CREATE DATABASE ${destination_database};"
fi

# restore db
echo "Step 5/6 - restore backup to the database ${destination_database}."
psql --dbname=postgresql://${destination_user}:${destination_password}@${destination_host}:5432/${destination_database} < ${filename}.sql
echo "Step 6/6 - backup completed."

# delete backup file
rm ${filename}.sql