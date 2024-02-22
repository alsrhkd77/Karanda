import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/channel.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/maretta/maretta_report_model.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

class MarettaReportDialog extends StatefulWidget {
  const MarettaReportDialog({super.key});

  @override
  State<MarettaReportDialog> createState() => _MarettaReportDialogState();
}

class _MarettaReportDialogState extends State<MarettaReportDialog> {
  AllChannel channel = Channel.kr.keys.first;
  int channelNumber = 1;
  TimeOfDay selectedTime = TimeOfDay.now();
  bool alive = false;

  Future<void> pickTime(BuildContext context) async {
    TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (selected != null) {
      setState(() {
        selectedTime = selected;
      });
    }
  }

  void report() {
    String reporter = context.read<AuthNotifier>().username;
    DateTime at = DateTime.now()
        .copyWith(hour: selectedTime.hour, minute: selectedTime.minute);
    if(at.difference(DateTime.now()).inHours > 12){
      at = at.subtract(const Duration(days: 1));
    }
    if(at.difference(DateTime.now()).inHours < -12){
      at = at.add(const Duration(days: 1));
    }
    print(at.difference(DateTime.now()).inHours);
    context.pop(MarettaReportModel(
        reporterName: reporter,
        reportAt: at,
        alive: alive,
        channel: channel,
        channelNum: channelNumber));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('제보하기'),
      scrollable: true,
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const TitleText('상태'),
                title: DropdownButton<bool>(
                  focusColor: Colors.transparent,
                  menuMaxHeight: 600,
                  borderRadius: BorderRadius.circular(8.0),
                  value: alive,
                  items: const [
                    DropdownMenuItem(
                      alignment: Alignment.center,
                      value: false,
                      child: Text('처치 확인'),
                    ),
                    DropdownMenuItem(
                      alignment: Alignment.center,
                      value: true,
                      child: Text('생존 확인'),
                    ),
                  ],
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        alive = value;
                      });
                    }
                  },
                  isExpanded: true,
                ),
              ),
              ListTile(
                leading: const TitleText('채널'),
                title: DropdownButton<AllChannel>(
                  focusColor: Colors.transparent,
                  menuMaxHeight: 600,
                  borderRadius: BorderRadius.circular(8.0),
                  value: channel,
                  items: Channel.kr.keys
                      .map<DropdownMenuItem<AllChannel>>((e) =>
                          DropdownMenuItem<AllChannel>(
                              value: e, child: Text(Channel.toKrServerName(e))))
                      .toList(),
                  onChanged: (AllChannel? value) {
                    if (value != null) {
                      setState(() {
                        channel = value;
                        channelNumber = 1;
                      });
                    }
                  },
                  isExpanded: true,
                ),
                trailing: DropdownButton<int>(
                  focusColor: Colors.transparent,
                  menuMaxHeight: 600,
                  borderRadius: BorderRadius.circular(8.0),
                  value: channelNumber,
                  items: List.generate(
                    Channel.kr[channel]!,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text('${index + 1}ch'),
                    ),
                  ),
                  onChanged: (int? value) {
                    if (value != null) {
                      setState(() {
                        channelNumber = value;
                      });
                    }
                  },
                ),
              ),
              ListTile(
                leading: const TitleText('시각'),
                title: TextButton(
                  onPressed: () => pickTime(context),
                  child: Text(selectedTime.timeWithPeriod()),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: report,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: const Text('제보'),
        )
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
