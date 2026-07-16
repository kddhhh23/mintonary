# 민터너리 (Mintonary) 개발 가이드

배드민턴 동호인을 위한 개인 운동 기록 · 장비 관리 · 지출 관리 앱

## 기술 스택

- 프론트엔드: Flutter
- 백엔드: Spring Boot (Java 21, Gradle - Groovy)
- 데이터베이스: MySQL
- 푸시 알림: FCM (Firebase Cloud Messaging)

## 프로젝트 구조 (모노레포)

```
mintonary/
├── README.md
├── .gitignore
├── app/        # Flutter (프론트엔드)
└── server/     # Spring Boot (백엔드)
```

### app/ 목표 구조 (Flutter)

```
app/lib/
├── main.dart
├── core/            # 공통 (상수, 테마, 네트워크, 유틸)
├── features/        # 기능별 폴더
│   ├── auth/
│   ├── record/
│   ├── equipment/
│   ├── dashboard/
│   ├── expense/
│   ├── notification/
│   └── community/
└── shared/          # 공용 위젯
```

각 feature 안은 `data/` (API·모델), `presentation/` (화면·상태관리)로 시작.
복잡해지면 `domain/` (비즈니스 로직) 추가.

### server/ 목표 구조 (Spring Boot)

```
server/src/main/java/com/mintonary/
├── MintonaryApplication.java
├── global/          # 공통 (config, exception, common)
└── domain/
    ├── auth/
    ├── member/
    ├── record/
    ├── equipment/
    ├── dashboard/
    ├── expense/
    └── notification/
```

각 도메인 안은 `controller/`, `service/`, `repository/`, `entity/`, `dto/`.

## Git 규칙

### 브랜치

- `main`: 항상 배포 가능한 안정 버전
- `feature/기능명`: 기능 단위 작업 (혼자 개발이라 app/server 한 브랜치에서 같이 작업)
- `fix/이름`: 버그 수정
- `refactor/이름`: 코드 정리

기능 브랜치 목록:
- `feature/auth` — 인증 (AUTH)
- `feature/record` — 운동 기록 (REC)
- `feature/equipment` — 장비 관리 (EQP)
- `feature/dashboard` — 홈 대시보드 (DASH)
- `feature/expense` — 지출 관리 (EXP)
- `feature/notification` — 알림 (FCM)
- `feature/community` — 커뮤니티 (COM)

작업 흐름:
```bash
git checkout -b feature/auth   # main에서 브랜치 생성
# 작업 & 커밋
git push -u origin feature/auth
# GitHub PR로 main에 머지 (또는 로컬 머지)
git branch -d feature/auth     # 다 쓴 브랜치 삭제
```

### 커밋 메시지

형식: `타입: 설명`

- `feat`: 새 기능 추가
- `fix`: 버그 수정
- `chore`: 설정·잡무 (초기 세팅, 의존성 추가 등)
- `docs`: 문서 작업
- `refactor`: 기능 변화 없는 코드 개선
- `style`: 코드 포맷 정리
- `test`: 테스트 코드

예시: `feat: 로그인 화면 구현`

## 개발 순서 (명세서 우선순위 기준)

Must → Should → Could 순서로 진행.

1. **auth** (인증) — Must, 진행 예정
2. **record** (운동 기록) — Must
3. **equipment** (장비 관리) — Must
4. **dashboard** (홈 대시보드) — Must/Should
5. **expense** (지출 관리) — Should
6. **notification** (알림/FCM) — Must
7. **community** (커뮤니티) — Could, 나중에

## 완료된 작업

- [x] GitHub 레포 생성 (mintonary, private, 모노레포)
- [x] Flutter 프로젝트 생성 (app/)
- [x] Spring Boot 프로젝트 생성 (server/)
  - 의존성: Spring Data JPA, Spring Web, Spring Boot DevTools, Lombok, MySQL Driver
- [x] .gitignore 작성 (Flutter + Spring Boot + 보안 파일 제외)
- [x] README.md 작성
- [x] main에 초기 세팅 커밋 & 푸시

## 다음 할 일 (feature/auth)

명세서 AUTH-01 ~ AUTH-04 구현.

### 준비
- [ ] `git checkout -b feature/auth` 로 브랜치 생성
- [ ] MySQL 설치 확인 및 로컬 DB 생성
- [ ] server의 application.yml에 MySQL 연결 설정 (DB 접속 정보는 별도 파일로 분리, .gitignore 처리)

### 백엔드 (server)
- [ ] Member 엔티티 작성 (필수: ID, PW, 이메일, 닉네임 / 선택: 나이, 성별, 급수, 경력)
- [ ] 회원가입 API (AUTH-01) — 이메일 인증 포함
- [ ] 로그인/로그아웃 API (AUTH-02) — 앱 자체 ID/PW
- [ ] 회원탈퇴 API (AUTH-03) — 확인 절차, 데이터 삭제 정책
- [ ] 아이디/비밀번호 찾기 (AUTH-04) — 이메일 인증
- [ ] Spring Security + JWT 도입 (build.gradle에 의존성 추가)

### 프론트엔드 (app)
- [ ] 회원가입 화면
- [ ] 로그인 화면
- [ ] 로그인 API 연동 (토큰 저장)
- [ ] 로그아웃 / 회원탈퇴 화면

## 검토 필요 (명세서 메모)

- 이메일 인증 대신 소셜 로그인(구글/카카오 OAuth) 도입 시, 이메일 인증
  인프라(SMTP, 토큰 관리)를 제거할 수 있음. 스택 결정 시 함께 판단.
- 인증 방식(이메일 vs 소셜)을 auth 개발 전에 먼저 결정할 것.

## 절대 커밋하면 안 되는 파일 (.gitignore로 관리)

- DB 접속 정보 (application-secret.yml 등)
- FCM 키 (google-services.json, serviceAccountKey.json)
- JWT 시크릿 키
- 빌드 산출물 (app/build/, server/build/ 등)
- IDE 설정 (.idea/, *.iml)
