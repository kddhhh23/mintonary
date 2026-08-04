# Mintonary

Flutter 앱(`app/`) + Spring Boot 서버(`server/`) 모노레포.

## 브랜치 규칙 (main - dev - feat)

- `main` — 최종(배포 가능한) 버전만 유지
- `dev` — 개발 내용을 모으는 브랜치, 완성된 기능을 여기에 머지
- `feat/기능이름` — `dev`에서 분기해 기능 단위로 작업, 완료 후 `dev`에 머지
- 흐름: `feat/기능이름` → `dev` → (안정화되면) `main`
- 머지 후 feature 브랜치 삭제

## 커밋 규칙

- 형식: `타입: 설명` — 설명은 한글로 작성
- 타입: `feat`(새 기능) / `fix`(버그 수정) / `chore`(설정·잡무) / `docs`(문서) / `refactor`(구조 개선) / `style`(포맷 정리) / `test`(테스트)
- 한 커밋에는 한 가지 변경만 담는다
