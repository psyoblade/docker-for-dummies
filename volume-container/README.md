# 볼륨 컨테이너를 통한 영속성이 보장되는 저장소 운영

## 1. 도커 create & volumes 명령어
* [docker create](https://docs.docker.com/engine/reference/commandline/create/) 
* [Use volumes](https://docs.docker.com/storage/volumes/)

## 2. 간단한 명령어 도커 컨테이너에 전송하기
```bash
# docker run [이미지] [명령어]
docker run -it ubuntu
```

## 3. 호스트 경로를 컨테이너에서 사용하는 방법
```bash
docker run --name ubuntu-16.04 -w /user/psyoblade -v `pwd`/host-volume:/user/psyoblade -it ubuntu:16.04
# -v {host-dir}:{guest-dir} 옵션으로 연결할 수 있고, --read-only 옵션으로 읽기 전용으로 연결할 수 있으며, -v 옵션을 연속으로 붙여쓸 수 있다
```

## 4. 도커 컨테이너 멈추지 않고 빠져나오는 방법 → Ctrl+P + Ctrl+Q
```bash
docker run -i -t
# Ctrl+P + Ctrl+Q 통해서 빠져나오면 컨테이너가 종료되지 않는다

docker run -i
# Ctrl+P + Ctrl+Q 통해서 나오는 경우 stdin 이 붕괴된다

docker run
# Ctrl+P + Ctrl+Q 통해서 빠져나올 수 없으며 SIGKILL 시그널로 컨테이너를 죽일 수 있다
```

5. 떠 있는 컨테이너에 접속하는 방법
```bash
docker exec -it container_name bash
# Ctrl+D 통해 종료해도 접속한 bash 만 종료되며 게스트 컨테이너는 살아있다
```

## 6. 데이터 볼륨 컨테이너 생성하는 방법
```bash
# docker create -v [생성될 볼륨 경로] --name [볼륨 이름] [이미지 이름]:[태그]
docker create -v `pwd`/data-volume:/data --name data-volume ubuntu:16.04
# 486ac04c086255edee4460643e908e2de107442efde20e3ac297cc8e7460de79 와 같은 값이 출력됩니다

touch data-volume/this-is-data-volume
# 호스트에서 임의의 파일을 생성한 다음

docker run --rm --volumes-from data-volume ubuntu:16.04 ls -la /data
# -rw-r--r-- 1 root root    0 Apr  4 08:28 this-is-data-volume
# 명령을 통해 확인할 수 있다

docker ps -a | grep ubuntu
# 아래와 같이 생성된 볼륨 컨테이너를 확인할 수 있다
# 486ac04c0862   ubuntu:16.04    "/bin/bash"    2 minutes ago       Created    data-volume
# 3b1a865e8a4c   ubuntu:16.04    "/bin/bash"    32 minutes ago      Created    data
```

## 7. 여러 컨테이너에서 데이터 볼륨 컨테이너를 활용하는 방법
```bash
docker run --name ubuntu-16.04 /user/psyoblade -v `pwd`/host-volume:/user/psyoblade --rm --volumes-from data-volume -it ubuntu:16.04
# root@febf6dafa228:/user/psyoblade# df -h
# Filesystem      Size  Used Avail Use% Mounted on
# overlay          59G  5.8G   50G  11% /
# tmpfs            64M     0   64M   0% /dev
# tmpfs           995M     0  995M   0% /sys/fs/cgroup
# shm              64M     0   64M   0% /dev/shm
# osxfs           466G  202G  244G  46% /data --> 
# /dev/sda1        59G  5.8G   50G  11% /etc/hosts
# tmpfs           995M     0  995M   0% /proc/acpi
# tmpfs           995M     0  995M   0% /sys/firmware

root@febf6dafa228:/user/psyoblade$ ls /data
# 아래와 같이 data-volume 컨테이너에 등록된 파일을 확인할 수 있다 
# this-is-data-volume
# 위와 같은 방식으로 여러 컨테이너에서 하나의 볼륨 컨테이너를 활용할 수 있습니다

docker inspect ubuntu-16.04
# 아래와 같이 마운트 된 정보를 확인할 수 있으며 volume 이나 volume container 모두 bind 유형으로 마운트 된 것을 확인할 수 있습니다
"Mounts": [
	{
		"Type": "bind",
		"Source": "/Users/psyoblade/git/psyoblade/docker-for-dummies/volume-container/data-volume",
		"Destination": "/data",
		"Mode": "",
		"RW": true,
		"Propagation": "rprivate"
	},
	{
		"Type": "bind",
		"Source": "/Users/psyoblade/git/psyoblade/docker-for-dummies/volume-container/host-volume",
		"Destination": "/user/psyoblade",
		"Mode": "",
		"RW": true,
		"Propagation": "rprivate"
	}
],
```

8. 생성된 컨테이너 및 볼륨 컨테이너 삭제
```bash
docker container stop ubuntu-16.04
docker container rm ubuntu-16.04
docker volume rm data-volume
```
