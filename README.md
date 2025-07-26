# Karanda

편의성 기능 모음

## 실행
### 개발 환경 args
```
 --web-port=2345 --dart-define=SECRET={SECRET_FROM_FIRESTORE} --dart-define=VAPID={SECRET_FROM_FIREBASE}
```

## 사용

- Link: [https://github.com/Hammuu1112/Karanda](https://github.com/HwanSangYeonHwa/Karanda)
- Web: [https://www.karanda.kr](https://www.karanda.kr)
- Windows Desktop App: [https://github.com/Hammuu1112/Karanda/releases](https://github.com/HwanSangYeonHwa/Karanda/releases)

## 개발 언어

[Flutter](https://flutter.dev/)를 사용하여 Web & Windows & Android용 Cross-Platform App으로 개발

[Inno Setup](https://jrsoftware.org/)을 사용하여 설치파일(.exe) 제작

## 핵심 기술
- **Provider**와 **RxDart**를 사용한 상태 관리
- **GoRouter**를 사용한 **URI기반 라우팅** 관리
- **Websocket STOMP**를 활용한 **실시간 알림**(Windows) 및 **데이터 업데이트**
- **FCM**을 사용한 **실시간 알림** (Web & Android)
- **Conditional import**, `kIsWeb`, `PlatformAPI`를 활용한 **다양한 플랫폼 분기 처리 방식** 구현
- **win32** 패키지를 활용해 **네이티브 코드 없이 Flutter만으로** 창 컨트롤 (Windows)
- JWT를 사용한 인증 관리
- 플랫폼별 **Discord OAuth2 인증** 플로우 완전 구현
