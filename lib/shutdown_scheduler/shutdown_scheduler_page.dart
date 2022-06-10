import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/date_time_converter.dart';
import 'package:karanda/shutdown_scheduler/shutdown_scheduler_notifier.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

class ShutdownSchedulerPage extends StatefulWidget {
  const ShutdownSchedulerPage({Key? key}) : super(key: key);

  @override
  State<ShutdownSchedulerPage> createState() => _ShutdownSchedulerPageState();
}

class _ShutdownSchedulerPageState extends State<ShutdownSchedulerPage> {
  DateTime selected = DateTime.now();
  final DateTimeConverter _dateTimeConverter = DateTimeConverter();

  void selectTime(){

  }

  Widget buildTimer(){
    return Container(
      margin: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('오전', style: (_dateTimeConverter.getAmPm(selected) == '오전') ? const TextStyle(fontWeight: FontWeight.bold) : null,),
          Text('오후', style: (_dateTimeConverter.getAmPm(selected) == '오후') ? const TextStyle(fontWeight: FontWeight.bold) : null,),
          Container(
            alignment: Alignment.center,
            child: Text('오전'),
          ),
        ],
      ),
    );
  }

  Widget buildTimePicker(){
    return Container(
      margin: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('오전', style: (_dateTimeConverter.getAmPm(selected) == '오전') ? const TextStyle(fontWeight: FontWeight.bold) : null,),
          Text('오후', style: (_dateTimeConverter.getAmPm(selected) == '오후') ? const TextStyle(fontWeight: FontWeight.bold) : null,),
          Container(
            alignment: Alignment.center,
            child: Text('오전'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (context, ShutdownSchedulerNotifier _shutdownSchedulerNotifier, _) {
        return Scaffold(
          appBar: const DefaultAppBar(),
          body: Container(
            margin: const EdgeInsets.all(12.0),
            constraints: const BoxConstraints(
              maxWidth: 1440,
            ),
            child: Column(
              children: [
                //Title
                const ListTile(
                  leading: Icon(FontAwesomeIcons.powerOff),
                  title: TitleText('예약 종료'),
                ),

                //contents
                Card(
                  child: Stack(
                    children: [
                      _shutdownSchedulerNotifier.running ? buildTimer() : buildTimePicker(),
                      Positioned(
                        child: IconButton(
                          icon: Icon(FontAwesomeIcons.screwdriverWrench),
                          onPressed: (){},
                        ),
                        right: 15.0,
                        top: 15.0,
                      ),
                    ],
                  ),
                ),

                //Build Button
                _shutdownSchedulerNotifier.running
                    ? ElevatedButton(
                        child: Container(
                          width: 720,
                          height: 40,
                          alignment: Alignment.center,
                          child: const Text('취소'),
                        ),
                        onPressed: _shutdownSchedulerNotifier.startSchedule,
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                      )
                    : ElevatedButton(
                        child: Container(
                          width: 720,
                          height: 40,
                          alignment: Alignment.center,
                          child: const Text('예약'),
                        ),
                        onPressed: _shutdownSchedulerNotifier.cancelSchedule,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
