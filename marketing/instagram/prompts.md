# 이미지 생성 프롬프트 기록

내장 이미지 생성 도구에 `app/assets/mintonary_icon.png`을 브랜드 스타일 참조 이미지로 제공했다.

## 공통 프롬프트

```text
Use case: ads-marketing
Asset type: square Instagram launch-grid post for the Korean badminton diary app Mintonary
Input images: Image 1 is the brand/style reference. Use its flat friendly illustration language, navy #45526D, cream, mint, and muted blue-gray palette.
Style/medium: polished minimal flat vector-like editorial graphic, warm and approachable, generous whitespace, clean Korean mobile-app brand aesthetic.
Composition/framing: square canvas, strong centered hierarchy, readable on a phone, consistent campaign system.
Constraints: Render only the exact quoted Korean text, perfectly spelled. Keep all text horizontal. No English, no fake UI text, no watermark, no extra logo wording.
```

## 게시물별 요청과 정확한 문구

1. 브랜드 소개: notebook and shuttlecock motif — `민터너리`, `나의 배드민턴 다이어리`
2. 월간 질문: cream monthly calendar and activity dots — `이번 달, 몇 번 쳤나요?`
3. 기록 종류: practice, lesson, competition badges — `운동 · 레슨 · 대회`, `한 번에 기록`
4. 캘린더: monthly calendar and shuttlecock path — `달력으로 보는`, `나의 배드민턴`
5. 장비: racket and court shoes — `라켓과 신발도`, `기록이 됩니다`
6. 교체 관리: grip roll, string reel, refresh arrow — `스트링 · 그립`, `교체 시기를 놓치지 않게`
7. 지출: won receipt and small chart — `배드민턴 지출도`, `한눈에`
8. 빠른 기록: shuttlecock motion and diary checkmark — `30초 운동 기록`
9. 베타 모집: welcoming notebook mascot and users — `민터너리`, `베타 테스터 모집`

## 둥근 서체 편집

현재 `posts` 폴더에 있는 01~08 이미지를 각각 편집 대상으로 제공하고 아래 공통 프롬프트를 적용했다.

```text
Use case: precise-object-edit
Asset type: square Korean Instagram post
Primary request: Change only the typography in the provided edit-target image to a friendly rounded Korean sans-serif. Use softly rounded corners and terminals, warm and approachable, bold and highly legible, not handwritten and not excessively bubbly.
Composition/framing: Preserve the exact canvas, text positions, line breaks, hierarchy, sizes, alignment, colors, and spacing.
Constraints: Preserve every illustration, object, shape, background, shadow, texture, color, and layout exactly. Change only the glyph style. Render every Korean character perfectly and preserve the exact original wording. Do not add or remove anything.
Avoid: spelling changes, new text, moved text, font size changes, altered illustrations, watermark.
```
