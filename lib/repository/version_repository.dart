import 'dart:async';

import 'package:karanda/data_source/version_data_source.dart';
import 'package:karanda/model/version.dart';

class VersionRepository {
  final VersionDataSource _dataSource;

  VersionRepository({required VersionDataSource dataSource})
      : _dataSource = dataSource;

  Future<Version> getCurrentVersion(){
    return _dataSource.getCurrentVersion();
  }

  Future<Version> getLatestVersion(){
    return _dataSource.getLatestVersion();
  }

  Stream<double> downloadLatest() async* {
    final uri  = await _dataSource.getAvailableApi();
    if(uri != null){
      yield* _dataSource.downloadLatestVersion(uri);
    } else {
      throw Exception("No downloads are available.");
    }
  }
}
