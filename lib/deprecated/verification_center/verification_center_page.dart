import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/deprecated/verification_center/family_verification_page.dart';
import 'package:karanda/deprecated/verification_center/models/bdo_family.dart';
import 'package:karanda/deprecated/verification_center/models/simplified_adventurer_card.dart';
import 'package:karanda/deprecated/verification_center/register_new_family_page.dart';
import 'package:karanda/deprecated/verification_center/services/verification_center_data_controller.dart';
import 'package:karanda/deprecated/verification_center/widgets/main_family_name_widget.dart';
import 'package:karanda/widgets/class_symbol_widget.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/loading_indicator_dialog.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

class VerificationCenterPage extends StatelessWidget {
  final VerificationCenterDataController dataController =
      VerificationCenterDataController();

  VerificationCenterPage({super.key});

  Future<void> deleteAdventurerCard(String code, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => LoadingIndicatorDialog(),
      barrierDismissible: false,
    );
    await dataController.deleteAdventurerCard(code);
    Navigator.of(context).pop();
  }

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
          ListTile(
            title: TitleText(
              context.tr('adventurer card.title'),
              bold: true,
            ),
          ),
          _AdventurerCards(
            data: dataController.adventurerCards,
            delete: deleteAdventurerCard,
          ),
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
    if (!context.watch<AuthNotifier>().authenticated) {
      return const _LoginRequired();
    }
    return StreamBuilder(
      stream: widget.dataController.families,
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

class _AdventurerCards extends StatelessWidget {
  final Stream<List<SimplifiedAdventurerCard>> data;
  final Future<void> Function(String, BuildContext) delete;

  const _AdventurerCards({super.key, required this.data, required this.delete});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: data,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }
        return Column(
          children: snapshot.requireData
              .map((item) => _AdventurerCardTile(
                    data: item,
                    delete: delete,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _AdventurerCardTile extends StatelessWidget {
  final SimplifiedAdventurerCard data;
  final Future<void> Function(String, BuildContext) delete;

  const _AdventurerCardTile({
    super.key,
    required this.data,
    required this.delete,
  });

  @override
  Widget build(BuildContext context) {
    final keywords = data.keywords.isEmpty ? "" : data.keywords;
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 16.0,
        ),
        leading: ClassSymbolWidget(className: data.mainClass.name),
        title: Text('$keywords #${data.region}'),
        subtitle: Text(data.publishedOn.format("yyyy.MM.dd")),
        trailing: IconButton(
          onPressed: () => delete(data.verificationCode, context),
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
        onTap: () {
          context.goWithGa(
              "/verification-center/adventurer-card/${data.verificationCode}");
        },
      ),
    );
  }
}

class _LoginRequired extends StatelessWidget {
  const _LoginRequired({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: Text(context.tr("login required")),
      ),
    );
  }
}
