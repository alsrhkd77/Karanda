# Release 버전 빌드
### 빌드 전 확인 사항
`pubspec.yaml`에 버전 확인하기

### Firebase 배포 명령어
```
firebase deploy --only hosting
```

# 구조
 - Data source: Local / asset 데이터
 - Api: Remote 데이터
 - Repository: 데이터 캐싱 및 제어
 - Service: 비즈니스 로직 (간단한 로직일 경우 생략, Repository에 역할 위임)
 - Controller: UI State

### 빌드 명령어
```
 flutter build {platform} --release --dart-define=SECRET={SECRET_FROM_FIRESTORE}
```

# 클래스 아이콘
공홈 클래스 svg 이용, 흰색 png 사용 - 80x80

svg -> png -> split png

# 이미지
대부분 `ui_texture > combine > etc`에 들어있음

### 전체 지도
`a1_worldmap_bg`

# 카리자드 관련 패치
[https://www.kr.playblackdesert.com/ko-KR/News/Detail?groupContentNo=13030&countryType=ko-KR](https://www.kr.playblackdesert.com/ko-KR/News/Detail?groupContentNo=13030&countryType=ko-KR)

# 기타
party = 파티
platoon = 부대

### Android 권한 요청 해야함
Media_kit 관련
[https://pub.dev/packages/media_kit](https://pub.dev/packages/media_kit)