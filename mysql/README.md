# 도커 컨테이너 활용기
> 도커 컨테이너를 통해 영속성 있는 저장소를 관리하고 MySQL 과 같은 데이터베이스의 저장소로 사용하는 것을 테스트 합니다


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

