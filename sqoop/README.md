# 도커 환경에서 스쿱을 통한 테이블을 수집해 보자
> 본 페이지는 아파치 하둡을 설치하고 테이블 수집 까지 수행하는 과정을 가이드 하는 페이지입니다. 아파치 스쿱의 경우 최소한 하둡 클라이언트가 설치되어 있어야만 하는데 맥의 경우 brew 를 통해 설치하고, 리눅스 OS 의 경우 별도로 설치하는 것이 일반적입니다.
> 하지만 본 페이지에서는 컨테이너 상에서 하둡과 스쿱을 설치하고, 별도의 컨테이너에서 MySQL 을 올려두고 수집하는 예제를 수행합니다

## 1. 하둡 및 스쿱 설치
* dvoros/docker-sqoop 을 fork 하여 sqoop-1.4.7 버전을 빌드합니다
```bash
        git clone git@github.com:psyoblade/docker-sqoop.git
        docker build -t dvoros/sqoop-hive:2.3.3 .
        docker 
```


## 2. MySQL 설치
* 컨테이너 기동 및 테스트 테이블 생성
```bash
        docker run -d --rm --name mysql -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" -v `pwd`/data/mysql:/var/lib/mysql -it mysql 
        docker exec -it mysql -uroot
        create database psyoblade
        use psyoblade
        create table users (id int, account varchar(100));
        insert into users values (1, 'psyoblade');
        insert into users values (2, 'chiyoung');
        insert into users values (3, 'ajg0716');
        insert into users values (4, 'shryu');
        insert into users values (5, 'jh9310s');
        insert into users values (6, 'leeyh0216');

    - 호스트 서버의 MySQL 접속 시에 mysql://host.docker.internal:3306/my_awesome_database 와 같이 접근이 가능합니다
    - docker.for.mac.host.internal 도 사용이 가능합니다.
```


## 3. Internal IP 확인
* 컨테이너 간의 통신은 network 통신이 가능해야 합니다
```bash

        docker inspect mysql # 명령을 통해 network 섹션을 확인합니다
        [생략]
        						"GlobalIPv6PrefixLen": 0,
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "MacAddress": "02:42:ac:11:00:02",
                    "Networks": {
                        "bridge": {
                            "IPAMConfig": null,
                            "Links": null,
                            "Aliases": null,
                            "NetworkID": "262cd6269a27c837f570cb6a3cc9ed665527e459b43acd0442d6ddd9e60f08e0",
                            "EndpointID": "2f05d5a0aacbd522120ae1941a6453bd960d81f6e8bf3fd9735a15f3c66e1f81",
                            "Gateway": "172.17.0.1",
                            "IPAddress": "172.17.0.2",
                            "IPPrefixLen": 16,
                            "IPv6Gateway": "",
                            "GlobalIPv6Address": "",
                            "GlobalIPv6PrefixLen": 0,
                            "MacAddress": "02:42:ac:11:00:02",
                            "DriverOpts": null
                        }
                    }
                }
            }
        ]
        
        # 네트워크 생성 후 다시 연결하는 방법도 있다
        docker network create sqoop-mysql
```


## 4. Sqoop 테스트
* 컨테이너 내에서 설치된 하둡을 통해 테이블 수집

```bash
        docker run -it -v `pwd`/jars:/usr/local/sqoop/jars dvoros/sqoop-hive:2.3.3
        
        docker exec -it sqoop bash
        cd /usr/local/sqoop
        
        # docker inspect mysql 을 통해 ip 확인 후 직접 접근하면 컨테이너 간에 접근이 가능합니다
        sqoop import \
        	-m 1 \
        	--connect jdbc:mysql://172.17.0.2:3306/psyoblade \
        	--username root \
        	--table users \
        	--target-dir /tmp/sqoop/t1
        
        # 생성된 네트워크를 통해서 접근
        docker network connect sqoop-mysql mysql
        sqoop import \
          -jt local \
          -fs local \
        	-m 1 \
        	--connect jdbc:mysql://mysql:3306/psyoblade \
        	--username root \
        	--table users \
        	--target-dir /tmp/sqoop/t2
        
        sqoop import \
          -jt local \
          -fs local \
        	--connect jdbc:mysql://mysql:3306/psyoblade \
        	--username root \
        	--table users \
          --split-by id \
        	--target-dir /tmp/sqoop/t3
```
