#!/bin/bash

# Database credentials
DB_USER=""
DB_PASSWORD=""
DB_NAME=""
DB_HOST=""
DB_PORT=""

# Connect to the automagicdeveloper database using psql
# Use \dt to list all tables in the current database
# Use awk to exclude the first two lines of output, which contain headers and a
# blank line
# Print the third column of each subsequent line, which contains the table name
TABLES=$(PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -h "$DB_HOST" \
  -p "$DB_PORT" -d "$DB_NAME" -c "\dt" | awk 'NR>2{print $3}')

# Loop through each table and get its size and number of lines
total_size=0
table_count=0
for TABLE in $TABLES
do
  # Use pg_total_relation_size() function to get the total size of the table in
  # bytes
  # Use sed to extract the third line of output, which contains the size in
  # bytes
  # Use sed again to remove any non-numeric characters from the output
  SIZE=$(PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -h "$DB_HOST" \
    -p "$DB_PORT" -d "$DB_NAME" -c "SELECT pg_total_relation_size('$TABLE');" \
    | sed -n 3p | sed 's/[^0-9]*//g')

  # Use count(*) function to get the number of lines in the table
  LINES=$(PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -h "$DB_HOST" \
    -p "$DB_PORT" -d "$DB_NAME" -c "SELECT count(*) FROM $TABLE;" \
    | sed -n 3p | sed 's/[^0-9]*//g')

  # Convert the size to KB and print the table name, size in KB, and number
  # of lines
  kb_size=$((SIZE / 1024))

  # Add the size to the total size
  total_size=$((total_size + kb_size))
  ((table_count++))
  echo "$TABLE: $kb_size KB ($LINES lines)"

done

# Convert the total size to MB and print the final report
total_size=$((total_size/1024))
printf "\n"
echo "Total size of the database $DB_NAME: $total_size MB"
echo "Total number of tables: $table_count"
