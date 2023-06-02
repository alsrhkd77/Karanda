import 'package:flutter/material.dart';
import 'package:karanda/checklist/checklist_item.dart';

class EditChecklistItemDialog extends StatefulWidget {
  final ChecklistItem item;
  final int index;
  final Function remove;
  final Function save;
  final Cycle cycle;

  const EditChecklistItemDialog(
      {Key? key, required this.item, required this.index, required this.remove, required this.save, required this.cycle})
      : super(key: key);

  @override
  State<EditChecklistItemDialog> createState() =>
      _EditChecklistItemDialogState();
}

class _EditChecklistItemDialogState extends State<EditChecklistItemDialog> {
  TextEditingController textEditingController = TextEditingController();
  late String title;
  late ChecklistItem item;
  late Cycle cycle;
  Map<Cycle, String> cycleType = {
    Cycle.once: '한 번',
    Cycle.daily: '매일',
    Cycle.weeklyMon: '매주 (월-일)',
    Cycle.weeklyThu: '매주 (목-수)',
  };

  @override
  void initState() {
    textEditingController.text = widget.item.title;
    title = widget.item.title;
    item = widget.item;
    cycle = widget.item.cycle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('편집'),
      contentPadding: const EdgeInsets.all(24.0),
      content: Container(
        width: Size.infinite.width,
        constraints: const BoxConstraints(
          maxWidth: 650,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'ex) 요리 황납, 항해 일퀘 등',
                  helperText: '체크할 숙제를 입력해주세요!',
                ),
                maxLength: 35,
                controller: textEditingController,
                onChanged: (value) {
                  setState(() {
                    title = value.trim();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text('반복'),
                trailing: DropdownButton<Cycle>(
                  underline: Container(),
                  focusColor: Colors.white.withOpacity(0),
                  value: cycle,
                  items: cycleType.keys
                      .map<DropdownMenuItem<Cycle>>((e) => DropdownMenuItem(
                            value: e,
                            child: Text(cycleType[e]!),
                          ))
                      .toList(),
                  onChanged: (Cycle? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      cycle = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red
          ),
          onPressed: () {
            widget.remove(widget.index, widget.item);
          },
          child: const Text('삭제'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
          onPressed: title.isEmpty
              ? null
              : () {
            item.title = textEditingController.text.trim();
            item.cycle = cycle;
            widget.save(widget.index, widget.cycle, item);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
