import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/common/channel.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/maretta/maretta_model.dart';

class MarettaDetailDialog extends StatefulWidget {
  final MarettaModel item;

  const MarettaDetailDialog({super.key, required this.item});

  @override
  State<MarettaDetailDialog> createState() => _MarettaDetailDialogState();
}

class _MarettaDetailDialogState extends State<MarettaDetailDialog> {
  late final MarettaModel item;

  @override
  void initState() {
    super.initState();
    item = widget.item;
  }

  String getStatus(){
    switch (item.status){
      case (MarettaStatus.alive):
        return '생존 확인';
      case (MarettaStatus.dead):
        return '처치 확인';
      case (MarettaStatus.unknown):
        return '확인 필요';
      default:
        return '확인 필요';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text('${Channel.toKrServerName(item.channel)} ${item.channelNumber}'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text('상태:  ${getStatus()}'),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text('제보 시간:  ${TimeOfDay.fromDateTime(item.report.first.reportAt).timeWithPeriod(period: 'KR', time: 'KR')}'),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text('제보자:  ${item.report.first.reporterName}'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            context.pop(true);
          },
          child: const Text('제보자 제외하기'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
        ),
        ElevatedButton(
            onPressed: () {
              context.pop(false);
            },
            child: const Text('닫기')),
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
