# 초보자를 위한 도커 머신 (Machine)
> 어느 정도 규모가 있는 환경에서 도커를 활용하기 위해서는 복수의 도커 노드를 구성해야만 하는데 이 때에 필요한 Docker Machine 기능에 대해 학습합니다
> 도커 머신은 도커화 된 호스트들을 관리하고 프로비져닝 하는 도구이다. 즉, 도커 엔진을 원격지의 장비 혹은 클라우드에 설치할 수 있도록 도와주는 도구입니다

## 참고 문서
* [Docker Machine](https://docs.docker.com/machine/)
* [Docker Machine으로 Docker Node 뿌리기](https://www.sauru.so/blog/provision-docker-node-with-docker-machine/)

### 1. 도커 머신의 설치
* [Docker Machine Download](https://github.com/docker/machine/releases/) 페이지를 통해 다운로드합니다
  - 시스템 권한의 도구가 아니라 다운로드 해서 사용하는 도구이므로 /usr/local/bin 이 아니라 $HOME/.local/bin 에 설치해도 무관합니다
* [Install-Machine](https://docs.docker.com/machine/install-machine/) 페이지를 통해 설치를 하고
* [Command-line Completion](https://docs.docker.com/machine/completion/) 페이지를 통해 자동완성 구성이 가능합니다
* [Docker Machine Drivers - Generic](https://docs.docker.com/machine/drivers/generic/)
