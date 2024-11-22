import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/verification_center/family_verification_page.dart';
import 'package:karanda/verification_center/models/bdo_family.dart';
import 'package:karanda/verification_center/register_new_family_page.dart';
import 'package:karanda/verification_center/verification_center_data_controller.dart';
import 'package:karanda/verification_center/widgets/main_family_name_widget.dart';
import 'package:karanda/widgets/class_symbol_widget.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';

class VerificationCenterPage extends StatelessWidget {
  final VerificationCenterDataController dataController =
      VerificationCenterDataController();

  VerificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        title: '인증 센터',
        icon: FontAwesomeIcons.idCard,
      ),
      body: CustomBase(
        children: [
          TextField(
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: '인증 카드의 검증 코드를 입력해주세요',
              labelText: '인증 카드 검증',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          SizedBox(height: GlobalProperties.scrollViewVerticalPadding),
          const ListTile(
            title: TitleText(
              '내 가문',
              bold: true,
            ),
          ),
          _Families(
            dataController: dataController,
          ),
          SizedBox(height: GlobalProperties.scrollViewVerticalPadding),
          const ListTile(
            title: TitleText(
              '내 인증 카드',
              bold: true,
            ),
          ),
          _VerificationCardTile(),
          _VerificationCardTile(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_task),
        label: const Text('가문 등록'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RegisterNewFamilyPage(
                dataController: dataController,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Families extends StatefulWidget {
  final VerificationCenterDataController dataController;

  const _Families({super.key, required this.dataController});

  @override
  State<_Families> createState() => _FamiliesState();
}

class _FamiliesState extends State<_Families> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.dataController.familyListStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        } else if (snapshot.requireData.isEmpty) {
          return const SizedBox(
            height: 40.0,
            child: Text("등록된 가문이 없습니다."),
          );
        }
        return Column(
          children: snapshot.requireData
              .map((family) => _FamilyTile(
                    family: family,
                    dataController: widget.dataController,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _FamilyTile extends StatelessWidget {
  final VerificationCenterDataController dataController;
  final BdoFamily family;

  const _FamilyTile(
      {super.key, required this.family, required this.dataController});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FamilyVerificationPage(
                dataController: dataController,
                familyData: family,
              ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: ClassSymbolWidget(className: family.mainClass.name),
        title: MainFamilyNameWidget(family: family),
        trailing: family.verified
            ? const Icon(
                Icons.verified,
                color: Colors.blueAccent,
              )
            : null,
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
