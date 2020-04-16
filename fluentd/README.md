# Docker for fluentd
> fluentd 실행을 위한 도커 설정 페이지입니다


## 설치
```bash
docker run -p 24224:24224 -p 24224:24224/udp -u fluent -v `pwd`/logs:/fluentd/log --name fluentd -dit fluentd
```
