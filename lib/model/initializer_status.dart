class InitializerStatus {
  double progress;
  String message;

  /// 임계(Phase 1) 단계가 실패했는지 여부. true면 스플래시가 진행 바 대신 에러를 표시한다.
  bool error;

  /// 재시도 가능한 실패인지 여부. true면 스플래시에 재시도 버튼을 노출한다.
  bool retryable;

  InitializerStatus({
    this.progress = 0,
    this.message = "preparing",
    this.error = false,
    this.retryable = false,
  });

  @override
  String toString() {
    return "initializer.$message";
  }
}
