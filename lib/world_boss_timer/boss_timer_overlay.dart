import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/real_time.dart';
import 'package:karanda/common/server_time.dart';
import 'package:karanda/common/time_of_day_extension.dart';

class BossTimerOverlay extends StatefulWidget {
  const BossTimerOverlay({super.key});

  @override
  State<BossTimerOverlay> createState() => _BossTimerOverlayState();
}

class _BossTimerOverlayState extends State<BossTimerOverlay> {
  DateTime? spawnTime;
  TimeOfDay timeOfDay = TimeOfDay.now();
  String? names;
  ServerTime serverTime = ServerTime();

  @override
  void initState() {
    super.initState();
    DesktopMultiWindow.setMethodHandler(callback);
  }

  Future<dynamic> callback(MethodCall call, int fromWindowId) async {
    if(call.method == 'next boss'){
      Map data = jsonDecode(call.arguments);
      setState(() {
        spawnTime = DateTime.parse(data["spawnTime"]);
        timeOfDay = TimeOfDay.fromDateTime(spawnTime!);
        names = data["names"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          color: Colors.black.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Clock(),
                Divider(),
                StreamBuilder(stream: serverTime.stream, builder: (context, snapshot){
                  if(!snapshot.hasData || spawnTime == null || names == null){
                    return Container();
                  }
                  Duration diff = spawnTime!.difference(snapshot.requireData);
                  TextStyle? style = Theme.of(context).textTheme.headlineSmall;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('${timeOfDay.timeWithoutPeriod()} $names', style: style,),
                        Text('${diff.inMinutes}분${diff.inSeconds % 60}초', style: style,)
                      ],
                    ),
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  RealTime realTime = RealTime();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: realTime.stream, builder: (context, snapshot){
      if(!snapshot.hasData){
        return Container();
      }
      return Container(
        width: Size.infinite.width,
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(snapshot.requireData.format('HH:mm:ss'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),),
      );
    });
  }
}


