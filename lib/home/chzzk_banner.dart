import 'dart:async';

import 'package:flutter/material.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/launch_url.dart';
import 'package:karanda/common/http.dart' as http;

class ChzzkBanner extends StatefulWidget {
  const ChzzkBanner({super.key});

  @override
  State<ChzzkBanner> createState() => _ChzzkBannerState();
}

class _ChzzkBannerState extends State<ChzzkBanner> {
  final StreamController controller = StreamController<bool>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => getLiveStatus());
  }

  @override
  void activate() {
    super.activate();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => getLiveStatus());
  }

  Future<void> getLiveStatus() async {
    bool result = false;
    try {
      final response = await http.get(Api.chzzkLiveStatus);
      if (response.statusCode == 200) {
        result = bool.tryParse(response.body) ?? false;
      }
    } catch (e) {
      print(e);
    } finally {
      controller.sink.add(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: false,
      stream: controller.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.requireData) {
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => launchURL(
                  'https://chzzk.naver.com/live/${GlobalProperties.chzzkChannelId}'),
              child: Image.asset('assets/image/live_banner.jpg',
                  fit: BoxFit.cover),
            ),
          );
        }
        return Container();
      },
    );
  }
}
