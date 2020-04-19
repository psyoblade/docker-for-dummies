# 컨테이너 기반 가상화 플랫폼 도커의 이해
> [T academy 컨테이너 기반 가상화 플랫폼 '도커(Docker)'의 이해](https://tacademy.skplanet.com/live/player/onlineLectureDetail.action?seq=125) 강좌를 듣고 실습 혹은 기억에 남았던 내용을 정리합니다


## 1. 도커 개요 및 소개
### 1-1. 리눅스 명령어 chroot 통한 컨테이너 실습
* 대상 경로를 / 경로로 인식하게 하고 격리된 런타임 환경을 제공하는 리눅스 도구
* 리눅스에서는 ldd 를 통해서 bash 의 의존성을 확인하고 해당 파일을 복사해 두고 사용할 수 있으며
  * 맥에서는 유사한 otool -L filename 으로 확인하여 의존성 라이브러리를 복사해 두고 가상화 환경을 구축할 수도 있습니다
* 아래와 같이 /usr/lib, /usr/lib/system 환경만 복사해 두면 격리된 bash 실행이 가능합니다
```bash
sudo chroot /Users/psyoblade/workspace/linux/box bash
bash-3.2#
```
* 초기 도커는 chroot, cgroups, namespaces, netlink, selinux, netfilter, capabilities 등의 명령어를 이용하여 컨테이너 가상화를 응용했습니다


## 2. 도커의 환경
> 도커는 리눅스 기반의 가상화 환경이라 네이티브 지원은 리눅스만 가능하고 가장 성능이 좋습니다. 맥이나 윈도우 환경에서도 다양한 시도가 일어나고 있어 그 격차는 점점 줄어들고는 있는 것 같습니다.

### 2-1. 리눅스 환경의 도커
* 개별 프로세스로 Client → Server + Container 기동이 되어 네이티브한 지원이 가능합니다

### 2-2. 맥 환경의 도커
* 경량화된 xhyve 가상 머신 위에서 Server + Container 가 기동되어 한 꺼풀 더 있는 상태에서 기동됩니다
  * [Docker Desktop on Mac vs. Docker Toolbox](https://docs.docker.com/docker-for-mac/docker-toolbox/)

### 2-3. 윈도우 환경의 도커
* 리눅스 컨테이너 or 윈도우 컨테이너 선택이 가능

### 2-4. 가상머신 위의 도커
* xhyve 대신 VirtualBox 라는 리눅스 이미지 위에서 동작합니다
* 호스트의 프로세스로 동작하지 않기 때문에 네트워크, 볼륨 등의 설정이 어렵다

### 2-5. 컨테이너의 필요성
* 독립성 : 컴퓨터의 환경이 항상 일치하지 않지만, 게스트 환경은 깔끔하게 새출발을 할 수 있고, 호스트 장비에 전혀 영향을 주지 않는다
* 재현성 : 다운로드 가능한 이미지는 정상이며, 항상 동일하게 동작함을 보장합니다
* 보안성 : 제한된 범위 내에서만 통신이 가능하며, 뚫리더라도 프로세스만 노출되는 것이므로 조금 더 안전하다 볼 수 있다



## 3. 꿀팁 모음
### 3-1. 호스트 컴퓨터에 텔넷이 설치되어 있지 않는 경우
```bash
# mikesplain/telnet
docker run mikesplain/telnet 192.168.0.17 8080
docker run mikesplain/telnet host.docker.internal 8080 # 호스트 IP
```

### 3-2. 호스트 접속을 좀 더 쉽게 하는 법 
* 도커 컨테이너의 IP 확인 후 IP 로 직접 접속
```bash
docker inspect container_name
```
* 도커 실행 시에 호스트 명령으로 localhost:port 방식으로 접속
```bash
docker run -it --net="host" container_name # net = {host,bridge,nat}
```

### 3-3. 컨테이너 로그를 출력 하는 방법
```bash
# docker logs
docker logs -f container_name
```

### 3-4. 가상 네트워크를 통한 컨테이너 간의 통신
* 네트워크를 생성하여 컨테이너를 생성해 보자
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
* 이미 생성된 컨테이너에 네트워크를 추가해 보자
```bash
docker network connect sqoop-mysql sqoop
docker network connect sqoop-mysql mysql
```
