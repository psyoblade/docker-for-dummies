# Docker for HUE, Hive, Hadoop
> 도커를 통해서 Hadoop, Hive 기반의 Hue 설정을 해보자

### 1. 데이터베이스 구성
> 기본 sqlite 의 경우 멀티쓰레드를 지원하지 않기 때문에 일반 관계형 데이터베이스(mysql, mariadb, postgresql)를 사용하기 위해 구성합니다
```bash
$ docker run --name mysql_server -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" -v `pwd`/data/mysql:/var/lib/mysql -dit mysql
$ docker exec -it mysql_server mysql -u root

mysql> create database hue default character set utf8 default collate utf8_general_ci;
mysql> create user 'hue'@'%' identified by '<password>';
mysql> gran all privileges on hue.* to 'hue'@'%';
mysql> flush privileges;

$ docker exec -it mysql_server mysql -u hue -P
mysql> show databases;
```

### 2. 휴(Hue) 및 하이브 초기 환경 구성
> Hive hive-site.xml 파일을 로컬에 복사하고, Hue hue.ini 파일을 수정합니다. 일부 포트가 충돌나는 경우는 -p 옵션으로 회피합니다
* 아래의 명령에 따라 설정파일을 로컬에 복사합니다
```bash
$ mkdir -p hive/conf
$ mkdir -p hue/conf
$ docker run --name hive_server -it dvoros/hive
$ docker cp hive_server:/usr/local/hive/conf/hive-site.xml hive/conf
$ docker run --name hue_server -p 8000:8888 -it gethue/hue
$ docker cp hue_server:/usr/share/hue/desktop/conf/hue.ini hue/conf
```
* Hue 설정파일(hue.ini)을 아래와 같이 변경합니다
```ini
[desktop]
  ...
  [[database]]
    engine=mysql
    host=<host>
    port=3306
    user=<user>
    password=<password>
    name=<database>
   ...
[beeswax]
  ...
  hive_server_host=<host>
  hive_server_port=10000
  hive_server_http_port=10001
  ...
  hive_metastore_host=<host>
  hive_metastore_port=9083
  hive_conf_dir=/etc/hive/conf
  ...
  thrift_version=7
  ...
```

### 3. 네트워크 및 컨테이너 구성
> MySQL -> Hive -> Hue 순서대로 기동합니다 
```bash
$ docker network create hue_network
$ docker run --name mysql_server --network=hue_network -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" -v `pwd`/data/mysql:/var/lib/mysql -dit mysql
$ docker run --name hive_server --network=hue_network -it dvoros/hive
$ docker run --name hue_server --network=hue_network -p 8000:8888 -v `pwd`/hive/conf:/etc/hive/conf -v `pwd`/hue/conf/hue.ini:/usr/share/hue/desktop/conf/z-hue.ini -it gethue/hue
```
* 네트워크 추가를 깜빡했다면 아래와 같이 추가합니다
```bash
$ docker network connect hue_network hive_server
$ docker network connect hue_network hue_server
$ docker network connect hue_network mysql_server
```

## 트러블슈팅
> 설치 시에 발생했던 다양한 문제점들
### 1. Could not connect to localhost:10000
> 별도의 컨테이너에 존재하므로, 도커 네트워크 생성 및 연동 후, hive-site.xml 및 hue.ini 설정 변경
### 2.  Thrift version configured by property thrift\_version might be too high
> hue.ini 설정에서 thrift\_version=7 로 변경
### 3. Failed to open new session: Permission denied: user=admin, access=EXECUTE, inode="/tmp":root:supergroup:drwxrwx---
> 도커의 /tmp 경로 권한 오류이므로 최초 로그인 시에 root 로 계정 생성
### 4. Resource Manager not available, trying another RM: YARN RM returned a failed response
> RM 연동을 안해서 발생하는 문제이므로 추후 연결
### 5. Autocomplete data fetching error: database is locked
> sqlite 를 사용하는 경우 multi-threaded 문제에 의한 것으로 msyql 로 변경
* [https://dev.mysql.com/doc/refman/8.0/en/create-user.html](https://dev.mysql.com/doc/refman/8.0/en/create-user.html)
* [https://docs.cloudera.com/documentation/enterprise/6/latest/topics/hue_dbs_mysql.html#hue_dbs_mysql](https://docs.cloudera.com/documentation/enterprise/6/latest/topics/hue_dbs_mysql.html#hue_dbs_mysql)
