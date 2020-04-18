# Docker for fluentd
> 도커 환경에서 fluentd 실습 및 학습을 위한 페이지입니다


## 1. 도커 컨테이너를 통한 Fluentd 기동 및 테스트 실습
> 몇 가지 제공되는 예제를 실습해보고 도커 환경에서 Fluentd 가 제대로 동작하는 지 확인합니다

### 1-1. 로컬 볼륨의 설정파일을 통한 Fluentd 실행
```bash
docker run -p 24224:24224 -p 24224:24224/udp -p 8888:8888 \
	-u fluent \
	-v `pwd`/logs:/fluentd/log \
	-v `pwd`/etc:/fluentd/etc \
	-v `pwd`/source:/fluentd/source \
	-v `pwd`/target:/fluentd/target \
	--name fluentd \
	-dit fluentd
```

### 1-2. 도커 상에서 in\_http 와 out\_stdout
```bash
docker run -p 24224:24224 -p 24224:24224/udp -p 8888:8888 \
		-u fluent \
		-v `pwd`/logs:/fluentd/log \
		-v `pwd`/etc:/fluentd/etc \
		-v `pwd`/source:/fluentd/source \
		-v `pwd`/target:/fluentd/target \
		--name fluentd \
		-dit fluentd
docker exec -it fluentd cat /fluentd/etc/fluent.conf

cat etc/fluent.conf
<source>
	@type http
	port 8888
	bind 0.0.0.0
</source>
<match test>
	@type stdout
</match>

# curl -i -X POST -d 'json={"action":"login","user":2}' http://localhost:8888/test
HTTP/1.1 200 OK
Content-Type: text/plain
Connection: Keep-Alive
Content-Length: 0

# docker logs -f fluentd
2020-04-16 17:01:13.756672881 +0000 test: {"action":"login","user":2}
2020-04-16 17:01:24.798792225 +0000 test: {"action":"login","user":2}
```


## 2. 대상 서버에서 HTTP 로 전송받은 JSON 로그를 전달하여 수집 서버에서 시간 단위로 로컬 파일로 저장
> 첫 번째 웹 서버 컨테이너에서는 docker-fluentd http 서버를 통해서 데이터를 전송 받을 수 있게 하고, 이를 두 번째 수집 컨테이너에서는 forward 플러그인을 통해 로컬에 저장합니다
> REST Client 전송은 [Advanced REST client](https://install.advancedrestclient.com/install) 크롬 플러그인을 사용합니다

### 2-1. 네트워크 및 웹서버 컨테이너를 생성후 테스트합니다
```bash
docker network create fluentdnet1 

docker run --name webserver1 \
    --network fluentnet1 \
    -p 24224:24224 -p 24224:24224/udp -p 8888:8888 \
    -u fluent \
    -v `pwd`/etc:/fluentd/etc \
    -v `pwd`/logs:/fluentd/log \
    -v `pwd`/source:/fluentd/source \
    -v `pwd`/target:/fluentd/target \
    -dit fluentd

docker logs -f webserver1

curl -i -X POST -d 'json={"event":"data"}' http://localhost:8888/datastaging

docker stop webserver1

docker run --name etlserver1 \
    --network fluentnet1 \
    -p 34224:24224 -p 34224:24224/udp -p 8889:8889 \
    -u fluent \
    -v `pwd`/etc:/fluentd/etc \
    -v `pwd`/logs:/fluentd/log \
    -v `pwd`/source:/fluentd/source \
    -v `pwd`/target:/fluentd/target \
    -dit fluentd

```

### 2-2. 웹 서버에서 HTTP 요청을 받아서 ETL 서버로 전송하는 fluent.conf 파일을 구성합니다
```bash
# webserver1 -> etlserver1
<system>
    log_level info
</system>

curl -i -X POST -d 'json={"event":"data"}' http://localhost:8888/<tag>

<source>
    @type http
    @id web_receive_http
    port 8888
    bind 0.0.0.0
    body_size_limit 1m
    keepalive_timeout 10s
</source>

<match debug>
    @type stdout
</match>

# match tag=system and forward to etlserver1
<match system>
    @type forward
    @id web_forward
    send_timeout 60s
    recover_wait 10s
    hard_timeout 60s

    <server>
        host etlserver1
        port 24224
    </server>

    <secondary>
        @type file
        path /fluentd/target/forward-failed
    </secondary>
</match>
```

### 2-3. 실행 중인 WEB 컨테이너를 종료/삭제 후, 지정한 설정파일을 통해 컨테이너를 다시 시작합니다
```bash
export role=webserver1 ;

docker rm -f $role ;

docker run --name $role --network fluentnet1 -p 24224:24224 -p 24224:24224/udp -p 8888:8888 \
    -u fluent \
    -v `pwd`/etc:/fluentd/etc \
    -v `pwd`/logs:/fluentd/log \
    -v `pwd`/source:/fluentd/source \
    -v `pwd`/target:/fluentd/target \
    -dit fluentd ;

docker logs -f $role
```

### 2-4. 포워드를 통해 수신한 이벤트 데이터를 로컬에 분 단위로 저장하는 fluent.conf 파일을 구성합니다
```bash
# etlserver1 -> localstorage
<system>
    log_level info
</system>

# built-in tcp input
<source>
    @type forward
    @id etl_receive_forward
</source>

<match debug>
    @type stdout
</match>

<match system>
    @type file
    time_slice_format %Y%m%d-%H%M
    localtime
    timezone Asia/Seoul
    path /fluentd/target/datastore
</match>

```

### 2-5. 실행 중인 ETL 컨테이너를 종료/삭제 후, 지정한 설정파일을 통해 컨테이너를 다시 시작합니다
```bash
export role=etlserver1 ; \
docker rm -f $role ; 
docker run --name $role --network fluentnet1 -p 34224:24224 -p 34224:24224/udp -p 9888:8888 \
    -u fluent \
    -v `pwd`/etc:/fluentd/etc \
    -v `pwd`/logs:/fluentd/log \
    -v `pwd`/source:/fluentd/source \
    -v `pwd`/target:/fluentd/target \
    -dit fluentd ; \
docker logs -f $role
```

