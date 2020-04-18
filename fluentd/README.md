# Docker for fluentd
> fluentd 실행을 위한 도커 설정 페이지입니다


## 설치
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

### 도커 상에서 in\_http 와 out\_stdout
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

$> cat etc/fluent.conf
<source>
	@type http
	port 8888
	bind 0.0.0.0
</source>
<match test>
	@type stdout
</match>

$> curl -i -X POST -d 'json={"action":"login","user":2}' http://localhost:8888/test
HTTP/1.1 200 OK
Content-Type: text/plain
Connection: Keep-Alive
Content-Length: 0

$> docker logs -f fluentd
2020-04-16 17:01:13.756672881 +0000 test: {"action":"login","user":2}
2020-04-16 17:01:24.798792225 +0000 test: {"action":"login","user":2}
```

## 실습

### 1. 대상 서버에서 HTTP 로 전송받은 JSON 로그를 전달하여 수집 서버에서 로컬 파일로 저장하시오
> 첫 번째 웹 서버 컨테이너에서는 docker-fluentd http 서버를 통해서 데이터를 전송 받을 수 있게 하고, 이를 두 번째 수집 컨테이너에서는 forward 플러그인을 통해 로컬에 저장합니다

```bash
% docker network create fluentdnet1 

% docker run --name webserver1 \
    --network fluentnet1 \
    -p 24224:24224 -p 24224:24224/udp -p 8888:8888 \
    -u fluent \
    -v `pwd`/etc:/fluentd/etc \
    -v `pwd`/logs:/fluentd/log \
    -v `pwd`/source:/fluentd/source \
    -v `pwd`/target:/fluentd/target \
    -dit fluentd

% docker logs -f webserver1

% curl -i -X POST -d 'json={"event":"data"}' http://localhost:8888/datastaging

% docker stop webserver1
```

* webserver1 -> etlserver1
```bash
<source>
	@type http
	port 8888
	bind 0.0.00
	body_size_limit 1m
	keepalive_timeout 10s
</source>

<match pattern>
	@type http
	endpoint http://etlserver1:8888/datastore
	open_timeout 2

	<format>
		@type json
	</format>
	<buffer>
		flush_interval 10s
	</buffer>
</match>
```

* etlserver1 -> local-storage
```bash
<source>
	@type http
	port 8888
	bind 0.0.0.0
	body_size_limit 1m
	keep_alive_timeout 10s
</source>

<match datastore>
	@type file
	path /fluentd/target/datastore
</match>

```


