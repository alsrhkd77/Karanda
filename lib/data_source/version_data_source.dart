import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:karanda/model/version.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';

class VersionDataSource {
  Future<Version> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return Version.fromString(packageInfo.version);
  }

  Future<Version> getLatestVersion() async {
    final response = await http.get(Uri.parse(KarandaApi.latestVersion));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Version.fromString(data['version']);
    }
    return Version(major: 0, minor: 0, patch: 0, text: "");
  }

  Future<String?> getAvailableApi() async {
    for (String path in KarandaApi.latestVersionMirrors) {
      final response = await http.head(Uri.parse(path));
      if (response.statusCode == 200) {
        return path;
      }
    }
    return null;
  }

  Stream<double> downloadLatestVersion(String api) async* {
    final path = '${Directory.current.path}/SetupKaranda.exe';
    final status = BehaviorSubject<double>();
    final dio = Dio();
    dio.download(api, path, onReceiveProgress: (received, total) {
      status.sink.add(received / total);
    }).then((value) => status.close());
    yield* status.stream;



    /*final file = File(path);
    StreamSubscription? subscription;

    int received = 0;
    if(file.existsSync()){
      await file.create();
    }
    file.writeAsBytesSync([]);
    final raf = await file.open();
    try {
      final request = http.Request('GET', api);
      final response = await http.Client().send(request);
      subscription = response.stream.listen(
        (chunk) {
          final contentLength = response.contentLength ?? 0;
          raf.setPositionSync(received);
          raf.writeFromSync(chunk);
          received += chunk.length;
          */ /*file.writeAsBytes(
            chunk,
            mode: FileMode.append,
            flush: contentLength == received,
          );*/ /*
          status.sink.add(received / contentLength);
        },
        onDone: () {
          raf.flushSync();
          raf.close();
          subscription?.cancel();
          status.close();
        },
        onError: (e) {
          throw Exception("Failed to download process\n$e");
        },
        cancelOnError: true,
      );
      yield* status.stream;
    } catch (e) {
      raf.close();
      file.deleteSync();
      throw Exception("Failed to download latest.\n$e");
    } finally {
      subscription?.cancel();
      status.close();
    }*/
  }
}
