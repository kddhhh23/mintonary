# 작업 규칙 (Claude Code용)

이 프로젝트에서 작업할 때 아래 규칙을 항상 따른다.
프로젝트의 상세 정보와 진행 상황은 `DEVELOPMENT_GUIDE.md`를 기준으로 한다.

## 진행 상황 관리

- 작업을 완료할 때마다 `DEVELOPMENT_GUIDE.md`의 체크리스트를 업데이트한다.
  - 완료한 항목은 `[ ]` → `[x]`로 변경
  - 새로 생긴 할 일은 해당 섹션에 추가
- 커밋 전에 `DEVELOPMENT_GUIDE.md`가 최신 상태인지 확인한다.

## Git 규칙

- 브랜치는 `feature/기능명` 형식으로 생성한다.
  (예: `feature/auth`, `feature/record`, `feature/equipment`)
  - 버그 수정은 `fix/이름`, 코드 정리는 `refactor/이름`
  - 혼자 개발이므로 app/server를 한 브랜치에서 같이 작업한다.
- `main`은 항상 배포 가능한 안정 상태로 유지한다.
- 커밋 메시지는 `타입: 설명` 형식을 따른다.
  - `feat`: 새 기능 / `fix`: 버그 수정 / `chore`: 설정·잡무
  - `docs`: 문서 / `refactor`: 코드 개선 / `style`: 포맷 / `test`: 테스트
  - 예: `feat: 로그인 화면 구현`
- 커밋은 의미 단위로 나눈다. 여러 기능을 한 커밋에 몰아넣지 않는다.

## 프로젝트 구조 (모노레포)

- `app/` — Flutter (프론트엔드), `lib/` 안을 `features/` 기능별로 분리
- `server/` — Spring Boot (백엔드), `domain/` 단위로 패키지 분리
- 자세한 목표 구조는 `DEVELOPMENT_GUIDE.md` 참고

## 보안 — 절대 커밋하지 않는 파일

다음 파일은 절대 커밋하지 않는다. 새로 생기면 `.gitignore`에 먼저 추가한다.

- DB 접속 정보 (application-secret.yml 등 DB 비밀번호 포함 파일)
- FCM 키 (google-services.json, serviceAccountKey.json)
- JWT 시크릿 키
- 빌드 산출물 (app/build/, server/build/ 등)
- IDE 설정 (.idea/, *.iml)

민감 정보는 코드에 하드코딩하지 말고 별도 설정 파일이나 환경 변수로 분리한다.

## 개발 순서

명세서 우선순위(Must → Should → Could) 기준으로 진행한다.
현재 순서: auth → record → equipment → dashboard → expense → notification → community

작업 시작 전 `DEVELOPMENT_GUIDE.md`의 "다음 할 일" 섹션을 확인한다.