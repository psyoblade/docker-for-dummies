# 도커 스웜 초기 구성
> 온프레미스 환경에서 도커스웜 구성을 위한 가이드라인을 작성합니다.
> 예제에서는 총 3대의 장비에 HA 구성을 고려한 클러스터를 구성하며, 도커 설치 등의 작업이 번거로울 수 있으므로 앤서블을 통해 설치합니다


## 앤서블 설치
```bash
bash> sudo apt update
bash> sudo apt install ansible -y
bash> cat /etc/ansible/hosts
[docker]
192.168.100.10
192.168.100.11
192.168.100.12


bash> lsb_release -a
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04.7 LTS
Release:	16.04
Codename:	xenial

bash> sudo apt install sshpass  # 각 노드에 설치가 필요함

bash> ssh-copy-id ubuntu@192.168.100.10
bash> ssh-copy-id ubuntu@192.168.100.11
bash> ssh-copy-id ubuntu@192.168.100.12

bash> ansible all -m ping

```

## 도커 설치
* [Install Docker on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

## 유저 생성
* [Create Docker User](https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/basic/README.md)


## 도커 스웜 클러스터 구성
* [Create a warm - docker.com](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/)
* [초보자를 위한 도커 - psyoblade](https://github.com/psyoblade/docker-for-dummies/tree/master/swarm)
* [Docker Swarm Orchestration - osci.kr ](https://tech.osci.kr/2019/02/13/59736201/)
* [Docker Swarm을 이용한 쉽고 빠른 분산 서버관리 - subicura](https://subicura.com/2017/02/25/container-orchestration-with-docker-swarm.html)
* [Docker Stack 이용한 관리 - hidekuma](https://hidekuma.github.io/docker/swarm/docker-swarm/)
* 도커 스웜 클러스터 초기화 및 매니저를 구성합니다
  - 초기화 한 이후에 워커 추가를 위한 토큰을 확인할 수 있습니다
  - 매니저 추가를 위한 토큰을 확인 후, 나머지 두 노드도 마스터로 추가합니다
```bash
bash> docker swarm init --advertise-addr <manager-node-ip>
bash> docker swarm join-token manager 
bash> docker swarm join --token <manager-token> <manager-node-ip>:2377
bash> docker node ls
```
* 추가된 노드에 nginx 웹 서버를 띄웁니다
```bash
bash> docker service create --name nginx -p 80:80 nginx
bash> curl -s http://<manager-ip>:80

bash> docker service update --replicas=3 nginx  # docker service scale nginx=3 
bash> curl -s http://<worker1-ip>:80
```
* 도커 스택을 통한 nginx 띄우기
  - 워커 노드에서 이미지를 pull 할 때, image 가 private 이라면, 워커 노드에서도 login 해야 하므로 로그인 정보를 전달해 주는 기능입니다
```bash
bash> cat nginx.yml
version: '3.7'
services:
  nginx:
    image: nginx
    ports:
      - '80:80'
    deploy:
      mode: replicated
      replicas: 3
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 5s

bash> docker stack -c ./nginx.yml --with-registry-auth swarm
```

## 헬로월드 배포

## 외부/내부 레지스트리 연결
