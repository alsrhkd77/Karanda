/// `FileSaver.saveBytes` 결과.
///
/// 플랫폼마다 최종 동작이 달라(저장 / 공유) 사용자에게 보여줄 안내 문구가 갈리므로 구분한다.
enum FileSaveResult {
  /// 다운로드 폴더에 저장되었거나(Windows) 브라우저 다운로드가 시작되었다(Web).
  saved,

  /// OS 공유 시트로 넘겼다(Android/iOS). 이후 처리는 사용자가 고른 앱이 담당한다.
  shared,

  /// 해당 플랫폼에서는 파일로 내보낼 수 없다.
  unsupported,
}
