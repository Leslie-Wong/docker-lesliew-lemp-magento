#!/bin/sh

DB_USER=$1
DATADIR=$2
INIT_SQL_ARG=""

if [ -z "$DB_USER" ]; then
    DB_USER="mysql"
fi
if [ -z "$DATADIR" ]; then
    DATADIR="/var/lib/mysql"
fi

# init DB if not exists
if [ ! -d "$DATADIR/mysql" ]; then
    mysql_install_db --user=$DB_USER --datadir=$DATADIR
    # cat /tmp/init_sql/*.sql > /tmp/init.sql
    # INIT_SQL_ARG="--init-file=/tmp/init.sql"
    sql=`mktemp`

    if [ ! -f "$sql" ]; then
        return 1
    fi
    cat << EOF > $sql
    USE mysql;
    FLUSH PRIVILEGES;
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
    ALTER USER 'root'@'%' IDENTIFIED BY '';
EOF

  mariadbd --user=root --bootstrap --verbose=0 < $sql
  rm -f $sql
fi



trap "mariadb-admin shutdown" TERM

mariadbd --user=$DB_USER --datadir=$DATADIR $INIT_SQL_ARG
