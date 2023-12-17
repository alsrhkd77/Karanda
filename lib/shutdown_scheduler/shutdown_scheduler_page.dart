import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/real_time_notifier.dart';
import 'package:karanda/common/time_of_day_extension.dart';
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

  Future<void> selectTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      initialTime: selected,
      helpText: '예약 종료',
      context: context,
    );
    if (selectedTime != null) {
      setState(() {
        selected = selectedTime;
      });
    }
  }

  Widget buildTimer(DateTime target) {
    return Text(
      target
          .difference(context.watch<RealTimeNotifier>().now)
          .toString()
          .split('.')
          .first,
      style: Theme.of(context)
          .textTheme
          .displayLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget buildTimePicker() {
    return InkWell(
      borderRadius: BorderRadius.circular(40.0),
      onTap: selectTime,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 48.0),
        child: Text(
          selected.timeWithPeriod(period: 'KR', time: 'KR'),
          style: Theme.of(context)
              .textTheme
              .displayLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Scaffold(
        appBar: DefaultAppBar(),
        body: CannotUseInWeb(),
      );
    }
    return Consumer(
      builder:
          (context, ShutdownSchedulerNotifier shutdownSchedulerNotifier, _) {
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
                  title: TitleText(
                    '예약 종료',
                    bold: true,
                  ),
                ),
              ),

              //contents
              Container(
                margin: const EdgeInsets.all(12.0),
                constraints: const BoxConstraints(
                  maxWidth: 1440,
                  minWidth: 620,
                ),
                height: MediaQuery.of(context).size.height / 2,
                child: Card(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      shutdownSchedulerNotifier.running
                          ? buildTimer(shutdownSchedulerNotifier.target)
                          : buildTimePicker(),
                      Positioned(
                        right: 15.0,
                        top: 15.0,
                        child: shutdownSchedulerNotifier.running
                            ? Row(
                                children: [
                                  Text(
                                    TimeOfDay.fromDateTime(
                                            shutdownSchedulerNotifier.target)
                                        .timeWithPeriod(
                                            period: 'KR', time: 'KR'),
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
                      ),
                    ],
                  ),
                ),
              ),
              //Build Button
              Container(
                margin: const EdgeInsets.all(12.0),
                width: 620,
                child: _BuildButton(
                  running: shutdownSchedulerNotifier.running,
                  start: () =>
                      shutdownSchedulerNotifier.startSchedule(selected),
                  cancel: shutdownSchedulerNotifier.cancelSchedule,
                ),
              ),
              const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}

class _BuildButton extends StatelessWidget {
  final VoidCallback? start;
  final VoidCallback? cancel;
  final bool running;

  const _BuildButton({super.key, required this.start, required this.cancel, required this.running});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: running ? cancel : start,
      style: running
          ? ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      )
          : null,
      onLongPress: (){
        context.read<ShutdownSchedulerNotifier>().forceCancel();
      },
      child: Container(
        height: 40,
        alignment: Alignment.center,
        child: Text(running ? '예약 취소' : '종료 예약'),
      ),
    );
  }
}
