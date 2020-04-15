# 도커 컨테이너 활용기
> 도커 컨테이너를 통해 영속성 있는 저장소를 관리하고 MySQL 과 같은 데이터베이스의 저장소로 사용하는 것을 테스트 합니다

## 볼륨 컨테이너 생성 및 활용
> 기본적으로 도커는 가상 머신처럼 작동하는 파일 시스템을 가지며, 이는 읽고 쓰고 하는 데에 전혀 문제가 없으나 해당 컨테이너 종료 시에 같이 사라지게 됩니다
```bash
# 아래의 명령으로 수행되는 bash 커맨드 라인은 임시로 생성되고 
docker run -it --name container-with-volume ubuntu:16.04 bash 
# 아래의 파일은 해당 컨테이너가 존재하는 동안에만 유지되는 임시 파일이라고 보시면 됩니다
touch hello_{1..10}
```

### 1. 도커 create & volumes 명령어
* [Docker create](https://docs.docker.com/engine/reference/commandline/create/) 
* [Use volumes](https://docs.docker.com/storage/volumes/)

### 2. 간단한 명령어 도커 컨테이너에 전송하기
```bash
# docker run [이미지] [명령어]
docker run -it ubuntu
```

### 3. 호스트 경로를 컨테이너에서 사용하는 방법
```bash
docker run --name ubuntu-16.04 -w /user/psyoblade -v `pwd`/host-volume:/user/psyoblade -it ubuntu:16.04
# -v {host-dir}:{guest-dir} 옵션으로 연결할 수 있고, --read-only 옵션으로 읽기 전용으로 연결할 수 있으며, -v 옵션을 연속으로 붙여쓸 수 있다
```
#### 도커 파일 내 명령어
* FROM → 태깅된 이미지로 부터 생성
* WORKDIR → 컨테이너에서 실행 시에 현재 경로를 지정
* COPY → 호스트 현재 위치에서 컨테이너로 복사
* RUN → 컨테이너 내부에서 실행될 명령어
* EXPOSE → 런타임 시에 리스닝 하고 있는 포트 목록을 노출
* CMD → 이 이미지를 실행하는 데에 사용되는 명령어를 알림

#### 도커 이미지 생성
* build → 도커 이미지 생성
  * docker build --tag bulletinboard:1.0 .
* run → 도커 컨테이너 실행
  * docker run --publish 8000:8080 --detach --name bb bulletinboard:1.0
* rm → 도커 컨테이너 삭제
  * docker rm --force bb # 종료와 삭제를 동시에
  
#### 도커 컴포즈 생성
* up → 도커 이미지 생성 후 포그라운드 상태로 컨테이너를 띄웁니다
  * docker-compose -f docker-compose.yml up
  * CTRL+C to quit : 이 때에 컨테이너도 종료됩니다
* cat docker-compose.yml
```yml
        version: "3"
        services:
            web:
                image: "compose-test:1.0"
                build: .
                ports:
                    - "5000:5000"
            redis:
                image: "redis:alpine"
```
  

### 4. 도커 컨테이너 멈추지 않고 빠져나오는 방법 → Ctrl+P + Ctrl+Q
```bash
docker run -i -t
# Ctrl+P + Ctrl+Q 통해서 빠져나오면 컨테이너가 종료되지 않는다

docker run -i
# Ctrl+P + Ctrl+Q 통해서 나오는 경우 stdin 이 붕괴된다

docker run
# Ctrl+P + Ctrl+Q 통해서 빠져나올 수 없으며 SIGKILL 시그널로 컨테이너를 죽일 수 있다
```

5. 떠 있는 컨테이너에 접속하는 방법
```bash
docker exec -it container_name bash
# Ctrl+D 통해 종료해도 접속한 bash 만 종료되며 게스트 컨테이너는 살아있다
```

### 6. 데이터 볼륨 컨테이너 생성하는 방법
```bash
# docker create -v [호스트_경로]:[게스트_경로] --name [볼륨_이름] [이미지_이름]:[태그]
docker create -v `pwd`/data-volume:/data --name data-volume ubuntu:16.04
# 486ac04c086255edee4460643e908e2de107442efde20e3ac297cc8e7460de79 와 같은 값이 출력됩니다

docker create -v /data --name data ubuntu
# 위와 같이 수행해도 호스트의 경로를 알아서 지정해 주고 ubuntu:latest 태그로 볼륨을 생성합니다 

touch data-volume/this-is-data-volume
# 호스트에서 임의의 파일을 생성한 다음

docker run --rm --volumes-from data-volume ubuntu:16.04 ls -la /data
# -rw-r--r-- 1 root root    0 Apr  4 08:28 this-is-data-volume
# 명령을 통해 확인할 수 있다

docker ps -a | grep ubuntu
# 아래와 같이 생성된 볼륨 컨테이너를 확인할 수 있다
# 486ac04c0862   ubuntu:16.04    "/bin/bash"    2 minutes ago       Created    data-volume
# 3b1a865e8a4c   ubuntu:16.04    "/bin/bash"    32 minutes ago      Created    data
```

### 7. 여러 컨테이너에서 데이터 볼륨 컨테이너를 활용하는 방법
```bash
docker run --name ubuntu-16.04 /user/psyoblade -v `pwd`/host-volume:/user/psyoblade --rm --volumes-from data-volume -it ubuntu:16.04
# root@febf6dafa228:/user/psyoblade# df -h
# Filesystem      Size  Used Avail Use% Mounted on
# overlay          59G  5.8G   50G  11% /
# tmpfs            64M     0   64M   0% /dev
# tmpfs           995M     0  995M   0% /sys/fs/cgroup
# shm              64M     0   64M   0% /dev/shm
# osxfs           466G  202G  244G  46% /data --> 
# /dev/sda1        59G  5.8G   50G  11% /etc/hosts
# tmpfs           995M     0  995M   0% /proc/acpi
# tmpfs           995M     0  995M   0% /sys/firmware

root@febf6dafa228:/user/psyoblade$ ls /data
# 아래와 같이 data-volume 컨테이너에 등록된 파일을 확인할 수 있다 
# this-is-data-volume
# 위와 같은 방식으로 여러 컨테이너에서 하나의 볼륨 컨테이너를 활용할 수 있습니다

docker inspect ubuntu-16.04
# 아래와 같이 마운트 된 정보를 확인할 수 있으며 volume 이나 volume container 모두 bind 유형으로 마운트 된 것을 확인할 수 있습니다
```
```json
{
"Mounts": [
	{
		"Type": "bind",
		"Source": "/Users/psyoblade/git/psyoblade/docker-for-dummies/volume-container/data-volume",
		"Destination": "/data",
		"Mode": "",
		"RW": true,
		"Propagation": "rprivate"
	},
	{
		"Type": "bind",
		"Source": "/Users/psyoblade/git/psyoblade/docker-for-dummies/volume-container/host-volume",
		"Destination": "/user/psyoblade",
		"Mode": "",
		"RW": true,
		"Propagation": "rprivate"
	}
]
}
```

### 8. 생성된 컨테이너 및 볼륨 컨테이너 삭제
```bash
docker container stop ubuntu-16.04
docker container rm ubuntu-16.04
docker volume rm data-volume
```

### 9. 다양한 옵션으로 볼륨을 로딩하는 cAdvisor 예제
```bash
docker run \
   --detach=true \
   --volume=/:/rootfs:ro \
   --volume=/var/run:/var/run:rw \
   --volume=/sys:/sys:ro \
   --volume=/var/lib/docker/:/var/lib/docker:ro \
   --publish=8080:8080 \
   --privileged=true \
   --name=cadvisor \
google/cadvisor:latest
```

### 10. 도커 관련 궁금한 점들
1. COPY 명령어가 현재 build 하는 pwd 에 존재하는 파일을 그대로 복사하는 구조가 아닌가?
    > COPY the file package.json from your host to the present location (.) in your image (so in this case, to /usr/src/app/package.json)
2. 임의의 파일이 변경되었을 때에 COPY 명령어가 변경 된 파일이 적용이 되는가?
    > 해당 컨테이너 아이디가 변경되어야 새로 생성된 이미지가 적용되므로, 반드시  rm 명령어로 컨테이너 종료 후 다시 run 해야만 적용됩니다
3. docker 와 docker-compose 를 통한 방식의 차이가 있는가?
    > 차이가 없으며 변경된 경우에는 반드시 docker build 명령을 통해 다시 해야만 합니다


### 11. 컨테이너 네트워크 설정을 통한 컨테이너간 연결
```bash
docker network create sqoop-mysql

cd /Users/psyoblade/git/psyoblade/docker-for-dummies/mysql
export MYSQL_OPTS="MYSQL_ALLOW_EMPTY_PASSWORD=yes"
docker run -dit --rm --name mysql --network=sqoop-mysql -v `pwd`/data/mysql:/var/lib/mysql -e $MYSQL_OPTS mysql:5.7

cd /Users/psyoblade/git/psyoblade/docker-sqoop
docker run -dit --rm --name sqoop --network=sqoop-mysql -v `pwd`/jars:/usr/local/sqoop/jars -v `pwd`/target:/tmp/sqoop dvoros/sqoop-hive:2.3.3

docker exec -it sqoop bash
cp jars/mysql-connector-java-8.0.19.jar lib
bin/sqoop import -fs local -jt local -m 1 --driver com.mysql.jdbc.Driver --connect jdbc:mysql://mysql:3306/psyoblade --table users --target-dir /tmp/sqoop/t1 --verbose --username root --relaxed-isolation
cat /tmp/sqoop/t1/part-m-00000
```



## 볼륨 컨테이너를 통한 MySQL 컨테이너 생성
> 굳이 별도로 빌드하지 않아도 영속성있는 저장소를 볼륨으로 지정하여 사용할 수 있습니다

### 1. 도커 이미지를 빌드 합니다
```bash
FROM mysql
VOLUME /var/lib/mysql
VOLUME /var/log

docker image build -t volume_container:latest .
# REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
# volume_container        latest              548f77daddb1        4 minutes ago       547MB
```

```bash
FROM busybox # 최소한의 운영체제 기능만 제공
VOLUME /var/lib/mysql
VOLUME /var/log
# docker image build -t [태그] [경로|URL]
docker image build -t volume_container:latest . # busybox 는 용량이 1.2MB 로 감소
```

* 아래의 2가지 명령어 모두 동일하게 볼륨 컨테이너를 생성합니다
```bash
docker container run --volumes-from volume_container mysql:5.7
docker create -v volume_container --name mysql-with-volume mysql:5.7
```

### 2. 빌드된 볼륨컨테이너를 이용하여 컨테이너를 실행합니다
```bash
docker run -d --rm --name mysql -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" --volumes-from mysql-with-volume mysql
# 이렇게 실행된 mysql 서버는 해당 컨테이너 이미지가 삭제되고 별도의 컨테이너에서 해당 볼륨 컨테이너에 접근해도 동일하게 동작합니다
```

### 3. 유사하게 몽고디비도 마찬가지 방식으로 실행이 가능합니다
```bash
docker run -v `pwd`/mongo-volume:/data/db mongo
```

