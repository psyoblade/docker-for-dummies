# Docker Q&A

## 1. 도커에서 수 많은 외부 장비 접근은 어떻게 하나요?
> 내부 장비의 경우 --add-host 플래그를 통해 추가하면 되지만, 장비가 많은 경우 어떻게 추가 관리하는 방법이 좋을지 확인합니다

### 1-1. alpine linux 를 구성하고 suhyuk 호스트를 ping 합니다
```bash
bash> docker run --rm -it alpine /bin/sh 
# ping suhyuk
ping: bad address 'suhyuk'

bash> docker run --rm -it --add-host suhyuk:127.0.0.1 alpine  /bin/sh
# ping suhyuk
64 bytes from 127.0.0.2: seq=0 ttl=64 time=0.041 ms

# grep suhyuk /etc/hosts
127.0.0.1 suhyuk
```


