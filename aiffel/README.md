# AIFFEL 실습 환경을 위한 도커 이미지 생성

## How to build ?
```bash
docker build -t ubuntu-aiffel:1.0.0 .
```

## How to run ?
* 직접 실행
```bash
docker run --name ubuntu-aiffel --rm -it ubuntu-aiffel:1.0.0 ./aiffel.sh sqoop
```
* 데몬으로 띄운 뒤 터미널로 접속하여 실행
```bash
docker run --name ubuntu-aiffel --rm -dit ubuntu-aiffel:1.0.0
docker exec -it ubuntu-aiffel bash
```
