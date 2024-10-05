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
  bool liveStatus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => getLiveStatus());
  }


  @override
  void activate() {
    super.activate();
    getLiveStatus();
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
      setState(() {
        liveStatus = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(liveStatus){
      return Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => launchURL('https://chzzk.naver.com/live/${GlobalProperties.chzzkChannelId}'),
          child: Image.asset('assets/image/live_banner.jpg', fit: BoxFit.cover),
        ),
      );
    }else{
      return Container();
    }
  }
}
