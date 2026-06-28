import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/model/operation_log_record.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/operation_log/controller/operation_log_controller.dart';
import 'package:provider/provider.dart';

class OperationLogPage extends StatelessWidget {
  const OperationLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KarandaAppBar(
        icon: Icons.receipt_long_outlined,
        title: context.tr("settings.operation log"),
      ),
      body: ChangeNotifierProvider(
        create: (context) => OperationLogController()..load(),
        child: Consumer(
          builder: (context, OperationLogController controller, child) {
            if (controller.isLoading) {
              return const LoadingIndicator();
            }
            final records = controller.records;
            if (records.isEmpty) {
              return Center(
                child: Text(context.tr("settings.operation log empty")),
              );
            }
            return PageBase(
              children: records
                  .map((record) => _LogTile(record: record))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final OperationLogRecord record;

  const _LogTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _levelIcon,
        color: _levelColor,
      ),
      title: Text(record.message),
      subtitle: Text(
        "${DateFormat('MM-dd HH:mm:ss').format(record.time)} · ${record.loggerName}",
        style: TextTheme.of(context).bodySmall?.copyWith(color: Colors.grey),
      ),
      isThreeLine: false,
    );
  }

  IconData get _levelIcon {
    switch (record.level) {
      case 'SHOUT':
      case 'SEVERE':
        return Icons.error_outline;
      case 'WARNING':
        return Icons.warning_amber_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color? get _levelColor {
    switch (record.level) {
      case 'SHOUT':
      case 'SEVERE':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      default:
        return null;
    }
  }
}
