import 'package:flutter/material.dart';
import 'package:karanda/checklist/checklist_item.dart';

class CreateChecklistItemDialog extends StatefulWidget {
  final Function create;
  const CreateChecklistItemDialog({Key? key, required this.create}) : super(key: key);

  @override
  State<CreateChecklistItemDialog> createState() => _CreateChecklistItemDialogState();
}

class _CreateChecklistItemDialogState extends State<CreateChecklistItemDialog> {
  String title = '';
  Cycle cycle = Cycle.daily;
  Map<Cycle, String> cycleType = {
    Cycle.once: '한 번',
    Cycle.daily: '매일',
    Cycle.weeklyMon: '매주 (월-일)',
    Cycle.weeklyThu: '매주 (목-수)',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새로 만들기'),
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

      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
          onPressed: title.isEmpty
              ? null
              : () {
                  ChecklistItem item =
                      ChecklistItem(title: title, cycle: cycle);
                  widget.create(item);
                },
          child: const Text('생성'),
        )
      ],
    );
  }
}
