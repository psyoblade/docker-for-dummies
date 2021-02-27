# AIFFEL 실습 환경을 위한 도커 이미지 생성

## How to build ?
```bash
docker build -t psyoblade/ubuntu-aiffel:1.0.0 .
```

## How to run ?
* 직접 실행
```bash
docker run --name ubuntu-aiffel --rm -it psyoblade/ubuntu-aiffel:1.0.0 ./aiffel.sh sqoop
```
* 데몬으로 띄운 뒤 터미널로 접속하여 실행
```bash
docker run --name ubuntu-aiffel --rm -dit psyoblade/ubuntu-aiffel:1.0.0
docker exec -it psyoblade/ubuntu-aiffel bash
```
