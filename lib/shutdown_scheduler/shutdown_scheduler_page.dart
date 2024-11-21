import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/real_time_notifier.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/shutdown_scheduler/shutdown_scheduler_notifier.dart';
import 'package:karanda/widgets/cannot_use_in_web.dart';
import 'package:karanda/widgets/default_app_bar.dart';
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
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget buildTimePicker() {
    return Text(
      selected.timeWithPeriod(period: 'KR', time: 'KR'),
      style: const TextStyle(fontWeight: FontWeight.bold),
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
          appBar: const DefaultAppBar(
            title: "예약 종료",
            icon: FontAwesomeIcons.powerOff,
          ),
          body: Padding(
            padding: GlobalProperties.scrollViewPadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1440,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: selectTime,
                          child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.expand,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 24.0,
                                  horizontal:
                                      MediaQuery.of(context).size.width / 15,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: shutdownSchedulerNotifier.running
                                      ? buildTimer(
                                          shutdownSchedulerNotifier.target)
                                      : buildTimePicker(),
                                ),
                              ),
                              Positioned(
                                right: 15.0,
                                top: 15.0,
                                child: shutdownSchedulerNotifier.running
                                    ? Row(
                                        children: [
                                          Text(
                                            TimeOfDay.fromDateTime(
                                                    shutdownSchedulerNotifier
                                                        .target)
                                                .timeWithPeriod(
                                                    period: 'KR', time: 'KR'),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: SpinKitHourGlass(
                                              color: Colors.blue,
                                              size: 25,
                                              duration: Duration(seconds: 2),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Icon(FontAwesomeIcons.clock),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    //Build Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: _BuildButton(
                        running: shutdownSchedulerNotifier.running,
                        start: () =>
                            shutdownSchedulerNotifier.startSchedule(selected),
                        cancel: shutdownSchedulerNotifier.cancelSchedule,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

  const _BuildButton(
      {super.key,
      required this.start,
      required this.cancel,
      required this.running});

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
      onLongPress: () {
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
