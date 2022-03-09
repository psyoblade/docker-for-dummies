# Github 가입 및 초기화
> 깃헙 가입 및 초기 설정 튜토리얼 입니다

## 1. 깃헙 가입
> [Sign-up Github](https://github.com/join) 페이지에 접속하여 username 생성 및 email 인증 후, 로그인합니다

## 2. 토큰 발급
> 화면과 같이 `Settings > Developer settings > Personal access tokens > Generate new tokens` 통하여 토큰을 생성합니다

[token](images/1.settings.png)
[token](images/2.dev-settings.png)
[token](images/3.access-token.png)

> 토큰의 범위(scopes)는 repo 만 선택합니다

[token](images/4.gen-token.png)

> 생성된 토큰은 최초 생성시에 한 번만 노출되므로 안전한 곳에 저장해 둡니다

[token](images/5.copy-token.png)


## 3. 예제 레포지토리 생성
> [Create new repository](https://github.com/new) 페이지에 접속하여 `ssm-seoul-tutorial` 레포지토리를 생성합니다

[token](images/6.clone.png)

> 생성된 레포지토리의 주소를 복사하여 터미널에서 코드를 클론 합니다

```bash
git clone https://github.com/<아이디>/ssm-seoul-tutorial.git
```

[token](images/7.clone.png)

> 해당 프로젝트에서 README.md 파일을 수정하고 코드를 서버로 업로드 합니다

```bash
echo "Hello world" > README.md
git commit -am "[수정] README.md"
git push
```

[token](images/8.push.png)

> 여기에서 `Username` 에는 나의 `아이디`를 넣고, `Password` 에는 아까 생성한 `<토큰>`을 붙여 넣습니다 



