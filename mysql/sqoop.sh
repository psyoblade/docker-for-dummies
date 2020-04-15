#!/bin/bash
echo "bin/sqoop import -fs local -jt local -m 1 --driver com.mysql.jdbc.Driver --connect jdbc:mysql://localhost:3306/psyoblade --table users --target-dir /Users/psyoblade/workspace/mysql-users --verbose --username root --relaxed-isolation"
