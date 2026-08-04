# Mintonary

Flutter 앱(`app/`) + Spring Boot 서버(`server/`) 모노레포.

## 브랜치 규칙 (GitHub Flow)

- `main`은 항상 동작하는 상태 유지
- 기능 작업은 `feat/기능이름` 브랜치에서 진행 후 `main`에 머지
- 머지 후 브랜치 삭제

## 커밋 규칙

- 형식: `타입: 설명` — 설명은 한글로 작성
- 타입: `feat`(새 기능) / `fix`(버그 수정) / `chore`(설정·잡무) / `docs`(문서) / `refactor`(구조 개선) / `style`(포맷 정리) / `test`(테스트)
- 한 커밋에는 한 가지 변경만 담는다
