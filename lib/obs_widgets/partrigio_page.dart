import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:karanda/common/bdo_world_time_notifier.dart';
import 'package:karanda/common/real_time_notifier.dart';
import 'package:provider/provider.dart';

class PartrigioPage extends StatelessWidget {
  List<TimeOfDay> timeTable = [
    const TimeOfDay(hour: 0, minute: 40),
    const TimeOfDay(hour: 4, minute: 40),
    const TimeOfDay(hour: 8, minute: 40),
    const TimeOfDay(hour: 12, minute: 40),
    const TimeOfDay(hour: 16, minute: 40),
    const TimeOfDay(hour: 20, minute: 40),
  ];
  
  DateTime target = DateTime.now();

  PartrigioPage({super.key}){
    update();
  }

  void update(){
    DateTime? result;
    if(target.isBefore(DateTime.now())){
      for(TimeOfDay timeOfDay in timeTable){
        DateTime time = DateTime.now().copyWith(hour: timeOfDay.hour, minute: timeOfDay.minute);
        if(DateTime.now().isBefore(time)){
          result = time;
          break;
        }
      }
      if(result == null){
        result = DateTime.now().copyWith(hour: 0, minute: 40);
        result = result.add(const Duration(days: 1));
      }
      target = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<RealTimeNotifier>(
        builder: (context, realtime, _){
          update();
          return Consumer<BdoWorldTimeNotifier>(
            builder: (context, notifier, _) {
              Color edgeColor = Colors.red;
              String txt = "";
              if (notifier.bdoTime.hour >= 22 || notifier.bdoTime.hour < 10) {
                edgeColor = Colors.green;
                txt = "비밀 상점 이용 가능!!";
              } else{
                if(target.difference(realtime.now).inSeconds < 60){
                  txt = "출현까지 ${target.difference(realtime.now).inSeconds + 1}초 남음";
                } else{
                  txt = "출현까지 ${target.difference(realtime.now).inMinutes + 1}분 남음";
                }
              }
              return Center(
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 38.0,
                          backgroundColor: edgeColor,
                          child: const CircleAvatar(
                            radius: 34.0,
                            backgroundImage: NetworkImage('https://s1.pearlcdn.com/KR/Upload/thumbnail/2024/OYGTTHH3I340M3KZ20240528190558057.400x225.png'),
                          ),
                        ),
                        Text(txt, style: const TextStyle(fontSize: 40, ),)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
