#!/bin/bash
echo "docker run --rm --name sqoop --network=sqoop-mysql -v `pwd`/jars:/usr/local/sqoop/jars -dit dvoros/sqoop-hive:2.3.3"
echo "cp jars/*.jar lib"
echo "mkdir target"
echo "bin/sqoop import -fs local -jt local -m 1 --driver com.mysql.jdbc.Driver --connect jdbc:mysql://mysql:3306/psyoblade --table users --target-dir /usr/local/sqoop/target/users --verbose --username root --relaxed-isolation"
