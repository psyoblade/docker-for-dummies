# AIFFEL 실습 환경을 위한 도커 이미지 생성

## How to build ?
```bash
docker build -t ubuntu-aiffel:1.0.0 .
```

## How to run ?
```bash
docker run --name ubuntu-aiffel --rm -it ubuntu-aiffel:1.0.0 sqoop
```
