import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/common/enums/recruitment_category.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';

class EditRecruitmentPage extends StatefulWidget {
  final Recruitment? recruitment;
  final RecruitmentCategory? category;

  const EditRecruitmentPage({super.key, this.recruitment, this.category});

  @override
  State<EditRecruitmentPage> createState() => _EditRecruitmentPageState();
}

class _EditRecruitmentPageState extends State<EditRecruitmentPage> {
  late RecruitmentCategory category;

  @override
  void initState() {
    category = widget.category ??
        widget.recruitment?.category ??
        RecruitmentCategory.values.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: "모집 공고 작성",
        icon: FontAwesomeIcons.circleNodes,
      ),
      body: Form(
        child: CustomBase(
          children: [
            ListTile(
              //title: Text(category.name),
              title: Text("파티 모집"),
              trailing: const Text("KR"),
            ),
            //mercenaries = 용병
            const Divider(),
            ListTile(
              //leading: Text("제목"),
              title: TextFormField(
                maxLength: 100,
                decoration: InputDecoration(label: Text("제목 (필수)")),
              ),
            ),
            ListTile(
              title: TextFormField(
                maxLength: 32,
                decoration: InputDecoration(labelText: '길드명 (필수)', counterText: ''),
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(labelText: '모집 인원 (필수)'),
              ),
            ),
            ListTile(
              title: Text("모집 유형"),
              trailing: DropdownMenu<String>(
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                    value: 'value',
                    label: 'Karanda reservation',
                  ),
                  DropdownMenuEntry(
                    value: 'value',
                    label: 'Ingame whisper',
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("즉시 모집 시작"),
              trailing: Checkbox(
                value: false,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: Text("모집 상세 내용"),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 18.0,
                right: 22.0,
                top: 4.0,
                bottom: 8.0,
              ),
              child: TextField(
                maxLines: null,
                minLines: 12,
                maxLength: 1024,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0)),
              ),
            ),
            ListTile(
              //leading: Text("제목"),
              title: TextFormField(
                decoration: InputDecoration(label: Text("Discord 초대 링크 (선택)")),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 20.0,
                top: 12.0,
                bottom: 8.0,
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(FontAwesomeIcons.penToSquare),
                label: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 8.0),
                  child: Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
