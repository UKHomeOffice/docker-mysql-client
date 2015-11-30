#!/usr/bin/env bash

set -e
export DEFAULT_PW=${DEFAULT_PW:-changeme}
export ROOT_PASS_SECRET=${ROOT_PASS_SECRET:-/etc/db/db-root-pw}
export APP_DB_NAME_SECRET=${APP_DB_NAME_SECRET:-/etc/db/db-name}
export APP_DB_USER_SECRET=${APP_DB_USER_SECRET:-/etc/db/db-username}
export APP_DB_PASS_SECRET=${APP_DB_PASS_SECRET:-/etc/db/db-password}
export ENABLE_SSL=${true}
export MYSQL_PORT="${MYSQL_PORT:-3306}"
if [ "${ENABLE_SSL}" == "TRUE" ]; then
    export SSL_OPTS="--ssl=true --ssl-ca=/root/rds-combined-ca-bundle.pem"
    export REQUIRE_SSL="REQUIRE SSL"
fi

function check_root {
	echo "Check default PW access..."
	err_txt=$(echo "SELECT 1+1;" | mysql --host=${MYSQL_HOST} --port=${MYSQL_PORT} ${SSL_OPTS} 2>/dev/stdout)
	if [ $? -ne 0 ]; then
		echo $err_txt | grep "ERROR 1045"
		if [ $? -eq 0 ]; then
			echo "Detected, Access denied error, now attempting reset FROM default password..."
			echo "SET PASSWORD FOR 'root'@'%' = PASSWORD('$(cat ${ROOT_PASS_SECRET} )');" | \
				mysql --host=${MYSQL_HOST} --port=${MYSQL_PORT} --user="root" --password="${DEFAULT_PW}" ${SSL_OPTS}
			if [ $? -ne 0 ]; then
				echo "ERROR resetting default password. Home time..."
				exit 1
			fi
		fi
	fi
}

MYSQL_HOST=$(eval echo ${MYSQL_HOST})
MYSQL_PORT=$(eval echo ${MYSQL_PORT})

echo "Downloading CA cert for mysql access"
curl -fail http://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem -o /root/rds-combined-ca-bundle.pem

# Allow for no passwords when running mysql as root...
echo "[client]
user=root
password=$(cat ${ROOT_PASS_SECRET})
">~/.my.cnf

set +e
check_root
set -e

refresh_sql=/tmp/refresh_users_and_db.sql

cat > "${refresh_sql}" <<-EOSQL
	CREATE DATABASE IF NOT EXISTS $(cat ${APP_DB_NAME_SECRET});
	grant all on $(cat ${APP_DB_NAME_SECRET}).* to
		'$(cat ${APP_DB_USER_SECRET})'@'%' identified by '$(cat ${APP_DB_PASS_SECRET})' ${REQUIRE_SSL};
	GRANT USAGE ON *.* TO 'root'@'%' ${REQUIRE_SSL};
	FLUSH PRIVILEGES;
EOSQL

echo "Update / create any database users..."
mysql --host=${MYSQL_HOST} --port=${MYSQL_PORT} ${SSL_OPTS} < ${refresh_sql}
