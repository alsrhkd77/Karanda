import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/verification_center/start_family_verification_page.dart';
import 'package:karanda/verification_center/verification_center_data_controller.dart';
import 'package:karanda/verification_center/widgets/main_family_chip.dart';
import 'package:karanda/widgets/class_symbol_widget.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';

class VerificationCenterPage extends StatelessWidget {
  final VerificationCenterDataController dataController =
      VerificationCenterDataController();

  VerificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        padding: GlobalProperties.scrollViewPadding,
        child: Column(
          children: [
            const ListTile(
              leading: Icon(FontAwesomeIcons.idCard),
              title: TitleText(
                '인증 센터',
                bold: true,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: GlobalProperties.widthConstrains,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: TextField(
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        counter: Container(),
                        hintText: '인증 카드의 검증 코드를 입력해주세요',
                        labelText: '인증 카드 검증',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: TitleText(
                      '내 가문',
                      bold: true,
                    ),
                  ),
                  _FamilyTile(),
                  _FamilyTile(),
                  const SizedBox(
                    height: 15,
                  ),
                  ListTile(
                    title: TitleText(
                      '내 인증 카드',
                      bold: true,
                    ),
                  ),
                  _VerificationCardTile(),
                  _VerificationCardTile(),
                ],
              ),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_task),
        label: const Text('가문 등록'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StartFamilyVerificationPage(
                dataController: dataController,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FamilyTile extends StatelessWidget {
  const _FamilyTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: ClassSymbolWidget(className: 'wizard'),
            title: Row(
              children: [Text('하라쿤타'), MainFamilyChip()],
            ),
            trailing: Icon(
              Icons.verified,
              color: Colors.blueAccent,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationCardTile extends StatelessWidget {
  const _VerificationCardTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: ClassSymbolWidget(className: 'dark knight'),
            title: Text('키워드 없음 #KR'),
            subtitle: Text(DateTime.now().format('yyyy.MM.dd')),
            trailing: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
          ),
        ),
      ),
    );
  }
}
