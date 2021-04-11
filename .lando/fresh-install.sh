#!/usr/bin/env bash

runtime=$(date +"%Y-%m-%d-%H-%M-%S")
alias="CLOUDWAYS-PROJECT-NAME"
remote="prod"
local="local"
site="default"

# Make sure we have contrib code.
composer install

## Start filling up local site.
echo "# Processing: $site:"

echo "* Fresh copy of local.settings.php"
if [ ! -f "/app/docroot/sites/$site/settings/settings.local.php" ]; then
   cp -TRv /app/.lando/templates/settings.local.php /app/docroot/sites/$site/settings/settings.local.php
fi

echo "* Make sure files directory is ready."
mkdir -p /app/docroot/sites/$site/files/private
mkdir -p /app/docroot/sites/$site/files/tmp
mkdir -p /app/docroot/sites/$site/files/translations
chmod -R 777 /app/docroot/sites/$site/files

echo "* Get remote DB from $remote."
if [ -f "/app/docroot/sites/$site/files/db_$remote.sql" ]; then
  echo "** /app/docroot/sites/$site/files/db_$remote.sql is already in place. Delete it and re-run lando fresh-install in case you want fresh DB."
else
  echo "* drush -Dssh.tty=0 @$alias.$remote sql-dump --structure-tables-key=common | pv > /app/docroot/sites/$site/files/db_$remote.sql"
  drush -Dssh.tty=0 @$alias.$remote sql-dump --structure-tables-key=common | pv > /app/docroot/sites/$site/files/db_$remote.sql
fi

echo "Make sure local site is ready: drush @$alias.$local status"
drush @$alias.$local status

echo "Wipe local DB: drush @$alias.$local sql-drop -y"
drush @$alias.$local sql-drop -y

echo "Import DB: cat /app/docroot/sites/$site/files/db_$remote.sql | pv | drush @$alias.$local sqlc"
cat /app/docroot/sites/$site/files/db_$remote.sql | pv | drush @$alias.$local sqlc

echo -e "\n\n"

# Show login links together at the end.
echo "$site is ready. You can now log in:"
drush @$alias.$local uli
