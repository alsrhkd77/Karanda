import 'package:flutter/material.dart';
import 'package:karanda/checklist/checklist_item.dart';
import 'package:karanda/checklist/checklist_finished_item.dart';
import 'package:karanda/checklist/checklist_item_provider.dart';

class ChecklistNotifier with ChangeNotifier {
  final _checklistItemProvider = ChecklistItemProvider();
  final GlobalKey<ScaffoldMessengerState> _rootScaffoldMessengerKey;

  Map<Cycle, List<ChecklistItem>> _checklistItem = {};

  bool get checklistItemIsNotEmpty =>
      _checklistItem.values.any((element) => element.isNotEmpty);

  List<ChecklistItem> get onceCycleItem => _checklistItem[Cycle.once] ?? [];

  List<ChecklistItem> get dailyCycleItem => _checklistItem[Cycle.daily] ?? [];

  List<ChecklistItem> get weeklyMonCycleItem =>
      _checklistItem[Cycle.weeklyMon] ?? [];

  List<ChecklistItem> get weeklyThuCycleItem =>
      _checklistItem[Cycle.weeklyThu] ?? [];

  ChecklistNotifier(this._rootScaffoldMessengerKey);

  Future<void> setFinish(
      int index, ChecklistItem item, DateTime selected) async {
    try {
      ChecklistFinishedItem finishedItem =
          await _checklistItemProvider.createFinishedItem(item.title, selected);
      _checklistItem[item.cycle]![index].finishedItem.add(finishedItem);
      notifyListeners();
    } catch (e) {
      _notifyException(e.toString());
    }
  }

  Future<void> removeFinish(
      int index, ChecklistItem checklistItem, int finishedItemIndex) async {
    bool result = await _checklistItemProvider.deleteFinishedItem(
        checklistItem.id!, checklistItem.finishedItem[finishedItemIndex].id!);
    if (result) {
      _checklistItem[checklistItem.cycle]![index]
          .finishedItem
          .removeAt(finishedItemIndex);
    }
    notifyListeners();
  }

  Future<void> createChecklistItem(ChecklistItem item) async {
    try {
      ChecklistItem result =
          await _checklistItemProvider.createChecklistItem(item);
      _checklistItem[result.cycle]!.add(result);
      notifyListeners();
    } catch (e) {
      _notifyException(e.toString());
    }
  }

  Future<void> getAllChecklistItems() async {
    try {
      _checklistItem = await _checklistItemProvider.getChecklistItems();
      notifyListeners();
    } catch (e) {
      _notifyException(e.toString());
    }
  }

  Future<void> deleteChecklistItem(int index, ChecklistItem item) async {
    bool result = await _checklistItemProvider.deleteChecklistItem(item.id!);
    if (result) {
      _checklistItem[item.cycle]?.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> updateChecklistItem(
      int index, Cycle cycle, ChecklistItem item) async {
    ChecklistItem? result =
        await _checklistItemProvider.updateChecklistItem(item);
    if (result != null) {
      _checklistItem[cycle]!.removeAt(index);
      _checklistItem[result.cycle]!.add(result);
      notifyListeners();
    }
  }

  void _notifyException(String txt) {
    _rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(txt),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24.0),
        backgroundColor:
            Theme.of(_rootScaffoldMessengerKey.currentState!.context)
                .snackBarTheme
                .backgroundColor,
      ),
    );
  }
}
