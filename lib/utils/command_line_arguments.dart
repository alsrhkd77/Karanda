class CommandLineArguments {
  static bool skipUpdate = false;
  static bool forceUpdate = false;

  static void setArguments(List<String> args){
    for(String value in args){
      switch(value){
        case("--skip-update"):
          skipUpdate = true;
          break;
        case("--force-update"):
          forceUpdate = true;
          break;
        default:
          break;
      }
    }
  }
}