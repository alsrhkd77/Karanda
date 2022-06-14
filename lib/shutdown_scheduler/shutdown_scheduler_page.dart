import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:karanda/common/date_time_converter.dart';
import 'package:karanda/shutdown_scheduler/shutdown_scheduler_notifier.dart';
import 'package:karanda/widgets/cannot_use_in_web.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

class ShutdownSchedulerPage extends StatefulWidget {
  const ShutdownSchedulerPage({Key? key}) : super(key: key);

  @override
  State<ShutdownSchedulerPage> createState() => _ShutdownSchedulerPageState();
}

class _ShutdownSchedulerPageState extends State<ShutdownSchedulerPage> {
  TimeOfDay selected = TimeOfDay.now();
  final DateTimeConverter _dateTimeConverter = DateTimeConverter();

  Future<void> selectTime() async {
    TimeOfDay? _selectedTime = await showTimePicker(
      initialTime: selected,
      helpText: '예약 종료',
      context: context,
    );
    if (_selectedTime != null) {
      setState(() {
        selected = _selectedTime;
      });
    }
  }

  Widget buildTimer(String intervalTime) {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: 20.0, vertical: context.height / 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            child: const Text('종료까지'),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              intervalTime,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 60.0),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            child: const Text('남았습니다'),
          ),
        ],
      ),
    );
  }

  Widget buildTimePicker() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: 20.0, vertical: context.height / 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.all(4.0),
                child: selected.period == DayPeriod.am
                    ? const Chip(
                        label: Text('오전'),
                        backgroundColor: Colors.blue,
                      )
                    : const Text('오전'),
              ),
              Container(
                margin: const EdgeInsets.all(4.0),
                child: selected.period == DayPeriod.pm
                    ? const Chip(
                        label: Text('오후'),
                        backgroundColor: Colors.blue,
                      )
                    : const Text('오후'),
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              _dateTimeConverter.getTime(selected),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 60.0),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            child: const Text('에 종료 예약'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(kIsWeb){
      return const Scaffold(
        appBar: DefaultAppBar(),
        body: CannotUseInWeb(),
      );
    }
    return Consumer(
      builder:
          (context, ShutdownSchedulerNotifier _shutdownSchedulerNotifier, _) {
        return Scaffold(
            appBar: const DefaultAppBar(),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Title
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: ListTile(
                    leading: Icon(FontAwesomeIcons.powerOff),
                    title: TitleText('예약 종료'),
                  ),
                ),

                //contents
                Container(
                  margin: const EdgeInsets.all(12.0),
                  constraints: const BoxConstraints(
                    maxWidth: 1440,
                    minWidth: 620,
                  ),
                  child: Card(
                    child: Stack(
                      children: [
                        _shutdownSchedulerNotifier.running
                            ? buildTimer(_shutdownSchedulerNotifier.getTimeInterval())
                            : buildTimePicker(),
                        Positioned(
                          child: _shutdownSchedulerNotifier.running
                              ? Row(
                                  children: [
                                    Text(
                                      '${_dateTimeConverter.getTimeWithAmPm(_shutdownSchedulerNotifier.target)}에 종료',
                                      style: TextStyle(
                                          color:
                                              context.textTheme.caption!.color),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: SpinKitHourGlass(
                                        color: Colors.blue,
                                        size: 25,
                                        duration: Duration(seconds: 2),
                                      ),
                                    ),
                                  ],
                                )
                              : IconButton(
                                  icon: const Icon(FontAwesomeIcons.clock),
                                  onPressed: selectTime,
                                ),
                          right: 15.0,
                          top: 15.0,
                        ),
                      ],
                    ),
                  ),
                ),
                //Build Button
                Container(
                  margin: const EdgeInsets.all(12.0),
                  child: _shutdownSchedulerNotifier.running
                      ? ElevatedButton(
                          child: Container(
                            width: 720,
                            height: 40,
                            alignment: Alignment.center,
                            child: const Text('취소'),
                          ),
                          onPressed: _shutdownSchedulerNotifier.cancelSchedule,
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
                          onPressed: () => _shutdownSchedulerNotifier
                              .startSchedule(selected),
                        ),
                ),
              ],
            ));
      },
    );
  }
}
