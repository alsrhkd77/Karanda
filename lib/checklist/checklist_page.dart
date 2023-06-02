import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/checklist/checklist_item.dart';
import 'package:karanda/checklist/checklist_notifier.dart';
import 'package:karanda/checklist/create_checklist_item_dialog.dart';
import 'package:karanda/checklist/edit_checklist_item_dialog.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator_dialog.dart';
import 'package:karanda/widgets/need_login.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({Key? key}) : super(key: key);

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<ChecklistNotifier>().getAllChecklistItems();
  }

  Future<void> createChecklistItemDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CreateChecklistItemDialog(
              create: createChecklistItem,
            ));
  }

  Future<void> editChecklistItemDialog(
      int index, ChecklistItem checklistCycleItem) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => EditChecklistItemDialog(
              item: checklistCycleItem,
              index: index,
              cycle: checklistCycleItem.cycle,
              remove: removeChecklistItem,
              save: editChecklistItem,
            ));
  }

  Future<void> loadingIndicatorDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => const LoadingIndicatorDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> createChecklistItem(ChecklistItem item) async {
    Navigator.of(context).pop();
    loadingIndicatorDialog();
    await context.read<ChecklistNotifier>().createChecklistItem(item);
    Navigator.of(context).pop();
  }

  Future<void> removeChecklistItem(int index, ChecklistItem item) async {
    Navigator.of(context).pop();
    loadingIndicatorDialog();
    await context.read<ChecklistNotifier>().deleteChecklistItem(index, item);
    Navigator.of(context).pop();
  }

  Future<void> editChecklistItem(
      int index, Cycle cycle, ChecklistItem item) async {
    Navigator.of(context).pop();
    loadingIndicatorDialog();
    await context
        .read<ChecklistNotifier>()
        .updateChecklistItem(index, cycle, item);
    Navigator.of(context).pop();
  }

  Widget buildChecklist(String title, List<ChecklistItem> items) {
    if (items.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        ListTile(
          title: TitleText(title),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            int? finished = items[index].isFinished(_selectedDay);
            return ListTile(
              onTap: () {
                if (finished == null) {
                  context
                      .read<ChecklistNotifier>()
                      .setFinish(index, items[index], _selectedDay);
                } else {
                  context
                      .read<ChecklistNotifier>()
                      .removeFinish(index, items[index], finished);
                }
              },
              leading: Icon(
                Icons.done,
                color: finished != null
                    ? Colors.blue
                    : Colors.grey.withOpacity(0.3),
              ),
              title: Text(
                items[index].title,
                style: finished == null
                    ? null
                    : const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        decorationThickness: 2.0,
                        decorationColor: Colors.grey,
                        color: Colors.grey,
                      ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => editChecklistItemDialog(index, items[index]),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<AuthNotifier>(context).authenticated) {
      return const Scaffold(
        appBar: DefaultAppBar(),
        body: NeedLogin(),
      );
    }
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(FontAwesomeIcons.listCheck),
              title: TitleText(
                '숙제 체크리스트 (Beta)',
                bold: true,
              ),
            ),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 1080,
              ),
              child: Consumer(
                builder: (context, ChecklistNotifier checklistNotifier, _) {
                  return Column(
                    children: [
                      TableCalendar(
                        firstDay:
                            DateTime.now().subtract(const Duration(days: 14)),
                        lastDay: DateTime.now().add(const Duration(days: 14)),
                        focusedDay: _focusedDay,
                        headerStyle: const HeaderStyle(
                          formatButtonShowsNext: false,
                        ),
                        calendarStyle: CalendarStyle(
                            weekendTextStyle:
                                const TextStyle(color: Colors.blue),
                            holidayTextStyle:
                                const TextStyle(color: Colors.red),
                            holidayDecoration: const BoxDecoration(
                                border: Border.fromBorderSide(BorderSide.none),
                                shape: BoxShape.circle),
                            tablePadding:
                                const EdgeInsets.symmetric(vertical: 12.0),
                            todayDecoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            disabledTextStyle:
                                TextStyle(color: Colors.grey.withOpacity(0.2))),
                        weekendDays: const [DateTime.saturday],
                        holidayPredicate: (DateTime day) {
                          if (day.weekday == DateTime.sunday) {
                            return true;
                          }
                          return false;
                        },
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (DateTime day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected:
                            (DateTime selectedDay, DateTime focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                            _selectedDay = selectedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        locale: 'ko_KR',
                      ),
                      const Divider(),
                      if (!checklistNotifier.checklistItemIsNotEmpty)
                        ListTile(
                            title: Text(
                          '체크 할 숙제를 추가해보세요!',
                          style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                        )),
                      buildChecklist('일일', checklistNotifier.dailyCycleItem),
                      buildChecklist(
                          '주간 (월요일 초기화)', checklistNotifier.weeklyMonCycleItem),
                      buildChecklist(
                          '주간 (목요일 초기화)', checklistNotifier.weeklyThuCycleItem),
                      buildChecklist('1회', checklistNotifier.onceCycleItem),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(
              height: 80.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '새로만들기',
        onPressed: createChecklistItemDialog,
        isExtended: false,
        child: const Icon(Icons.add_task),
      ),
    );
  }
}
