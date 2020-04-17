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
