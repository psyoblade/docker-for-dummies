# Docker for HUE, Hive, Hadoop
> 도커를 통해서 Hadoop, Hive 기반의 Hue 설정을 해보자


## I. 설치 및 환경 설정
> 도커 환경에서 하이브 및 HUE 를 통해서 데이터 조회 및 처리를 테스트합니다

### 1. 데이터베이스 구성
> 기본 sqlite 의 경우 멀티쓰레드를 지원하지 않기 때문에 일반 관계형 데이터베이스(mysql, mariadb, postgresql)를 사용하기 위해 구성합니다
```bash
$ docker run --name mysql_server -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" -v `pwd`/data/mysql:/var/lib/mysql -dit mysql
$ docker exec -it mysql_server mysql -u root

mysql> create database hue default character set utf8 default collate utf8_general_ci;
mysql> create user 'hue'@'%' identified by '<password>';
mysql> gran all privileges on hue.* to 'hue'@'%';
mysql> flush privileges;

$ docker exec -it mysql_server mysql -u hue -p
mysql> show databases;
```

### 2. 휴(Hue) 및 하이브 초기 환경 구성
> Hive hive-site.xml 파일을 로컬에 복사하고, Hue hue.ini 파일을 수정합니다. 일부 포트가 충돌나는 경우는 -p 옵션으로 회피합니다. 하이브의 경우 Hue 를 통해 직접 파일을 액세스하기 위해서 특정 경로를 볼륨으로 마운트하고 사용할 수 있어야 합니다
* 아래의 명령에 따라 설정파일을 로컬에 복사합니다
```bash
$ mkdir -p hive/conf
$ mkdir -p hue/conf
$ docker run --name hive_server -v `pwd`/hql:/data/hql -it dvoros/hive
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
$ docker run --name hive_server --network=hue_network -v `pwd`/data:/tmp/data -dit dvoros/hive
$ docker run --name hue_server --network=hue_network -p 8000:8888 -v `pwd`/hue/conf/hue.ini:/usr/share/hue/desktop/conf/z-hue.ini -it gethue/hue
```
* 네트워크 추가를 깜빡했다면 아래와 같이 추가합니다
```bash
$ docker network connect hue_network hive_server
$ docker network connect hue_network hue_server
$ docker network connect hue_network mysql_server
```

### 4. 하둡 & 얀 연동
```bash
docker run --name hadoop_server --network=hue_network -p 8088:8088 -dit sequenceiq/hadoop-docker:2.7.0 /etc/bootstrap.sh -bash

cd $HADOOP_PREFIX
# run the mapreduce
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.0.jar grep input output 'dfs[a-z.]+'

# check the output
bin/hdfs dfs -cat output/*

docker network connect hue_network hadoop_server

```



### 8. 트러블슈팅
* 1. Could not connect to localhost:10000
  * 별도의 컨테이너에 존재하므로, 도커 네트워크 생성 및 연동 후, hive-site.xml 및 hue.ini 설정 변경
* 2.  Thrift version configured by property thrift\_version might be too high
  * hue.ini 설정에서 thrift\_version=7 로 변경
* 3. Failed to open new session: Permission denied: user=admin, access=EXECUTE, inode="/tmp":root:supergroup:drwxrwx---
  * 도커의 /tmp 경로 권한 오류이므로 최초 로그인 시에 root 로 계정 생성
* 4. Resource Manager not available, trying another RM: YARN RM returned a failed response
  * RM 연동을 안해서 발생하는 문제이므로 추후 연결
* 5. Autocomplete data fetching error: database is locked
  * sqlite 를 사용하는 경우 multi-threaded 문제에 의한 것으로 msyql 로 변경
  * [https://dev.mysql.com/doc/refman/8.0/en/create-user.html](https://dev.mysql.com/doc/refman/8.0/en/create-user.html)
  * [https://docs.cloudera.com/documentation/enterprise/6/latest/topics/hue_dbs_mysql.html#hue_dbs_mysql](https://docs.cloudera.com/documentation/enterprise/6/latest/topics/hue_dbs_mysql.html#hue_dbs_mysql)

### 9. 참고 링크
* https://hub.docker.com/r/gethue
* https://gethue.com/hue-in-docker/
* https://github.com/dvoros/docker-hive
* https://gethue.com/getting-started-with-hue-in-2-minutes-with-docker/



## II. 데이터 연동 및 테스트
> 도커 환경에서 하이브 및 HUE 를 통해서 데이터 조회 및 처리를 테스트합니다

### 1. 하이브 서버에 데이터 업로드 및 하이브 테이블 생성
> 실제 하이브 명령이 수행되는 장비는 하이브 서버인 hive\_server 이므로 /tmp/input.txt 파일을 csv 포맷으로 저장해둡니다.
```bash
touch /tmp/input.txt
echo "1,suhyuk" >> /tmp/input.txt
echo "2,chiyoung" >> /tmp/input.txt
echo "3,ajg0716" >> /tmp/input.txt
cat /tmp/input.txt
```
> HUE 데이터 입력 화면에서 아래와 같이 테이블 생성 및 조회를 테스트 합니다
```sql
drop table if exists foo;
create table foo (id int, name string) row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
   "separatorChar" = ",",
   "quoteChar"     = "'",
   "escapeChar"    = "\\"
) ;
load data local inpath '/tmp/input.txt' into table foo;
show tables;
select * from foo;
```
* 좀 더 간단한 명령을 통해 테이블 생성도 가능합니다
```sql
drop table if exists bar;
create table bar(id int, name string) row format delimited fields terminated by ',' stored as textfile;
load data local inpath '/tmp/input.txt' into table bar;
select id, name from bar;
```

### 2. 로컬에서 파케이 파일 읽어들이기
```bash
java -jar ./parquet-tools-<VERSION>.jar --help
```

### 5. 참고링크
* https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL#LanguageManualDDL-CreateTable
* https://github.com/apache/parquet-mr/tree/master/parquet-tools
* https://github.com/Teradata/kylo/tree/master/samples/sample-data/parquet



## III. 도커 컴포즈를 통한 배포
> 기존의 이미지들을 올리기에는 매번 명령어를 직접 수정해야 하거나 개별 컨테이너를 컨트롤하기에 귀찮았을텐데 도커 컴포즈를 이용해서 의존성 및 모든 컨테이너를 한 번에 생성 및 기동을 할수 있습니다
* 기존의 hue.ini 파일에서 컴포즈를 사용하는 경우 시퀀스가 붙기 때문에 호스트 명을 변경해 주어야만 합니다
```bash
...
  host=hue_mysql_1
  hive_server_host=hue_hive_1
  hive_metastore_host=hue_hive_1
...
```
* 기존에 생성된 네트워크를 사용하는 경우에는 external networks 연결을 해줄 수 있다 (기본 ingress 네트워크가 생성되므로 굳이 쓸 필요는 없다)
```yml
services:
    mysql:
        networks:
            - hue_network
networks:
    hue_network:
        external: true
```
* 환경변수를 지정하여 bind volume 의 경우에도 전체경로를 docker-compose.yml 파일에 포함하지 않아도 됩니다
```bash
export PROJECT_HOME=`pwd` ; docker-compose up
```
