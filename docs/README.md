# 민터너리 공개 안내 페이지

- 개인정보 처리방침: https://kddhhh23.github.io/mintonary/privacy-policy.html
- 앱 소개: https://kddhhh23.github.io/mintonary/
- 호스팅: GitHub Pages, 로그인 없이 공개 접근

Play Console의 개인정보 처리방침 항목에는 위 처리방침 URL을 입력한다.
앱 시작 화면과 홈 하단의 버튼도 같은 URL을 기본 브라우저로 연다.

## 수정 및 배포

원본은 이 폴더의 `index.html`, `privacy-policy.html`, `styles.css`,
`assets/mintonary_icon.png`다.

GitHub 저장소의 Settings → Pages에서 `Deploy from a branch`, `dev`,
`/docs`를 게시 소스로 사용한다. 변경 사항을 원격 `dev` 브랜치에 반영하면
자동 배포된다. Actions에서 Pages 배포 성공 여부를 확인한다.

앱에서 사용하는 URL은 `app/lib/widgets/privacy_policy_button.dart`의
`privacyPolicyUrl`에 정의되어 있다.
