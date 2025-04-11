class InitializerStatus {
  double progress;
  String message;

  InitializerStatus({this.progress = 0, this.message = "preparing"});

  @override
  String toString() {
    return "initializer.$message";
  }
}
