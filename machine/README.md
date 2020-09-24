# 초보자를 위한 도커 머신 (Machine)
> 어느 정도 규모가 있는 환경에서 도커를 활용하기 위해서는 복수의 도커 노드를 구성해야만 하는데 이 때에 필요한 Docker Machine 기능에 대해 학습합니다
> 도커 머신은 도커화 된 호스트들을 관리하고 프로비져닝 하는 도구이다. 즉, 도커 엔진을 원격지의 장비 혹은 클라우드에 설치할 수 있도록 도와주는 도구입니다

## 참고 문서
* [Docker Machine](https://docs.docker.com/machine/)
* [Docker Machine Overview](https://docs.docker.com/machine/overview)
* [Docker Machine으로 Docker Node 뿌리기](https://www.sauru.so/blog/provision-docker-node-with-docker-machine/)
* [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### 1. 도커 머신의 설치
* [Docker Machine Download](https://github.com/docker/machine/releases/) 페이지를 통해 다운로드합니다
  - 시스템 권한의 도구가 아니라 다운로드 해서 사용하는 도구이므로 /usr/local/bin 이 아니라 $HOME/.local/bin 에 설치해도 무관합니다
* [Install-Machine](https://docs.docker.com/machine/install-machine/) 페이지를 통해 설치를 하고
* [Command-line Completion](https://docs.docker.com/machine/completion/) 페이지를 통해 자동완성 구성이 가능합니다
* [Docker Machine Drivers - Generic](https://docs.docker.com/machine/drivers/generic/)

* 도커 머신으로 무엇을 할 수 있는가?
  - 맥 혹은 윈도우에서 도커를 설치하고 실행할 수 있습니다
  - 다수의 원격 도커 호스트들을 프로비져닝하고 관리할 수 있습니다
  - 스웜 클러스터를 프로비져닝 할 수 있습니다

> 도커 머신 명령어를 통해 원격지에 Docker 설치 및 관리를 할 수 있습니다

```bash
zsh: command not found: __docker_machine_ps1

bash>
source /etc/bash_completion.d/docker-machine-prompt.bash

bash>
[\u@\h \W]$ eval "$(docker-machine env default)"
[\u@\h \W [default0]]$

```


### 2. 온프레미스 환경에서 도커 스웜 클러스터 구성

* OS 설치 및 환경설정 여부 확인
  - 디스크 저장공간은 충분한지?
  - ulimits 같은 값들은 제대로 구성되어 있는지?
* [Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/) 메뉴얼을 따라 설치
  - 설치 후에 도커 이미지 저장 볼륨의 크기는 적절한지?
  - 코어, 메모리의 최대치는 어떻게 설정했는지?
* 사이트 환경에 맞는 레포지토리 설정을 수행
  - dockerhub.com 이 아니라 별도의 레포지토리 설정은 어떻게 하는지?


