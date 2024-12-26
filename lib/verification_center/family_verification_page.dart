import 'package:flutter/material.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/real_time.dart';
import 'package:karanda/verification_center/models/bdo_family.dart';
import 'package:karanda/verification_center/verification_center_data_controller.dart';
import 'package:karanda/verification_center/widgets/main_family_name_widget.dart';
import 'package:karanda/widgets/class_symbol_widget.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator_dialog.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

class FamilyVerificationPage extends StatefulWidget {
  final VerificationCenterDataController dataController;
  final BdoFamily familyData;

  const FamilyVerificationPage(
      {super.key, required this.dataController, required this.familyData});

  @override
  State<FamilyVerificationPage> createState() => _FamilyVerificationPageState();
}

class _FamilyVerificationPageState extends State<FamilyVerificationPage> {
  late BdoFamily familyData;

  @override
  void initState() {
    familyData = widget.familyData;
    super.initState();
  }

  Future<void> unregister() async {
    bool? check = await showDialog(
      context: context,
      builder: (context) => const _FamilyUnregisterDialog(),
    );
    if (check != null && check) {
      showLoadingDialog();
      bool result = await widget.dataController
          .unregister(familyData.region, familyData.code);
      if (mounted) {
        if (result) {
          Provider.of<AuthNotifier>(context, listen: false)
              .authorization(); // update user info
          Navigator.of(context).pop();
        } else {
          showFailedSnackBar();
        }
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> refresh() async {
    showLoadingDialog();
    BdoFamily? newFamily =
        await widget.dataController.refresh(familyData.region, familyData.code);
    if (mounted) {
      if (newFamily != null) {
        setState(() {
          familyData = newFamily;
        });
        BdoFamily? mainFamily =
            Provider.of<AuthNotifier>(context, listen: false).mainFamily;
        if (mainFamily != null && mainFamily.code == familyData.code) {
          Provider.of<AuthNotifier>(context, listen: false)
              .authorization(); // update user info
        }
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> setMain() async {
    showLoadingDialog();
    bool result =
        await widget.dataController.setMain(familyData.region, familyData.code);
    if (mounted) {
      if (result) {
        Provider.of<AuthNotifier>(context, listen: false)
            .authorization(); // update user info
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> verify() async {
    bool? start = await showDialog(
      context: context,
      builder: (context) => _VerificationDialog(
        isPrivate: familyData.lifeSkillIsPrivate,
      ),
    );
    if (start != null && start) {
      showLoadingDialog();
      BdoFamily? result = await widget.dataController
          .verify(familyData.region, familyData.code);
      if (mounted) Navigator.of(context).pop();
      if (result == null) {
        showFailedSnackBar();
      } else {
        setState(() {
          familyData = result;
        });
        if (result.verified && mounted) {
          Provider.of<AuthNotifier>(context, listen: false)
              .authorization(); // update user info
          showVerificationCompleteSnackBar();
        } else {
          showNextVerificationSnackBar();
        }
      }
    }
  }

  void showFailedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [
          Icon(
            Icons.report_problem_outlined,
            color: Colors.red,
          ),
          SizedBox(
            width: 8.0,
          ),
          Text("요청 실패. 잠시 후 다시 시도해주세요."),
        ],
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: GlobalProperties.snackBarMargin,
    ));
  }

  void showVerificationCompleteSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [
          Icon(
            Icons.done_all,
            color: Colors.green,
          ),
          SizedBox(
            width: 8.0,
          ),
          Text("가문 인증이 완료되었습니다."),
        ],
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: GlobalProperties.snackBarMargin,
    ));
  }

  void showNextVerificationSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [
          Icon(
            Icons.done,
            color: Colors.green,
          ),
          SizedBox(
            width: 8.0,
          ),
          Text("인증이 처리되었습니다. 다음 단계를 진행해주세요."),
        ],
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: GlobalProperties.snackBarMargin,
    ));
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingIndicatorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        title: "가문 인증 정보",
        icon: Icons.add_task,
      ),
      body: CustomBase(
        children: [
          _Profile(familyData: familyData),
          familyData.verified && familyData.lastUpdated != null
              ? _RefreshButton(
                  lastUpdated: familyData.lastUpdated!,
                  onPressed: refresh,
                )
              : const SizedBox(),
          _SetMainFamilyButton(
            family: familyData,
            onPressed: setMain,
          ),
          Container(
            width: Size.infinite.width,
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: unregister,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('가문 삭제'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: familyData.verified
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: const Text('인증 카드 발급'),
              icon: const Icon(Icons.add_card),
            )
          : FloatingActionButton.extended(
              onPressed: verify,
              label: const Text('인증 진행'),
              icon: const Icon(Icons.fact_check_outlined),
            ),
    );
  }
}

class _Profile extends StatelessWidget {
  final BdoFamily familyData;

  const _Profile({super.key, required this.familyData});

  @override
  Widget build(BuildContext context) {
    const TextStyle leadingStyle = TextStyle(fontSize: 16);
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              leading: const Text('가문명:', style: leadingStyle),
              title: MainFamilyNameWidget(family: familyData),
            ),
            ListTile(
              leading: const Text('서버:', style: leadingStyle),
              title: Text(familyData.region),
            ),
            ListTile(
              leading: const Text('대표 클래스:', style: leadingStyle),
              title: Row(
                children: [
                  Text(familyData.mainClass.name),
                  ClassSymbolWidget(
                    className: familyData.mainClass.name,
                  )
                ],
              ),
            ),
            ListTile(
              leading: const Text('인증 상태:', style: leadingStyle),
              title: _VerifiedText(verified: familyData.verified),
            ),
            ListTile(
              leading: const Text('인증 시작:', style: leadingStyle),
              title: Text(
                  familyData.startVerification?.toLocal().format(null) ?? "-"),
            ),
            ListTile(
              leading: const Text('1단계 인증:', style: leadingStyle),
              title: Text(
                  familyData.firstVerification?.toLocal().format(null) ?? "-"),
            ),
            ListTile(
              leading: const Text('2단계 인증:', style: leadingStyle),
              title: Text(
                  familyData.secondVerification?.toLocal().format(null) ?? "-"),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationDialog extends StatefulWidget {
  final bool isPrivate;

  const _VerificationDialog({super.key, required this.isPrivate});

  @override
  State<_VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<_VerificationDialog> {
  final Map<bool, String> mapping = {true: "비공개", false: "공개"};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('가문 인증'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: "모험가 프로필의 "),
                TextSpan(
                    text: "생활 레벨",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: " 공개 여부\n변경 후 확인 버튼을 눌러주세요!"),
                /*
                * Change the visibility of Life Skill levels in the
                * Adventurer profile, then hit the “Confirm” button.
                * */
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
              '1단계 인증: ${mapping[widget.isPrivate]} → ${mapping[!widget.isPrivate]}'),
          Text(
              '2단계 인증: ${mapping[!widget.isPrivate]} → ${mapping[widget.isPrivate]}'),
        ],
      ),
      contentPadding: const EdgeInsets.all(24.0),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("확인"),
        ),
      ],
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final DateTime lastUpdated;
  final Function() onPressed;

  const _RefreshButton(
      {super.key, required this.onPressed, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: RealTime().stream,
      builder: (context, snapshot) {
        bool show = true;
        if (snapshot.hasData &&
            lastUpdated
                .add(const Duration(minutes: 10))
                .isAfter(snapshot.requireData.toUtc())) {
          show = false;
        }
        return Container(
          width: Size.infinite.width,
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: show ? onPressed : null,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('갱신하기'),
            ),
          ),
        );
      },
    );
  }
}

class _SetMainFamilyButton extends StatelessWidget {
  final BdoFamily family;
  final Function() onPressed;

  const _SetMainFamilyButton(
      {super.key, required this.family, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    BdoFamily? mainFamily = Provider.of<AuthNotifier>(context).mainFamily;
    if (family.verified && (mainFamily == null || mainFamily != family)) {
      return Container(
        width: Size.infinite.width,
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: onPressed,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('대표 가문으로 설정'),
          ),
        ),
      );
    }
    return const SizedBox();
  }
}

class _FamilyUnregisterDialog extends StatefulWidget {
  const _FamilyUnregisterDialog({super.key});

  @override
  State<_FamilyUnregisterDialog> createState() =>
      _FamilyUnregisterDialogState();
}

class _FamilyUnregisterDialogState extends State<_FamilyUnregisterDialog> {
  final String targetText = 'UNREGISTER';
  bool check = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('가문 삭제'),
      contentPadding: const EdgeInsets.all(48.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TitleText('주의 사항'),
          const SizedBox(
            height: 12,
          ),
          const Text(
              '1. 가문 삭제 시 연결된 인증 카드도 모두 삭제됩니다.\n2. 삭제된 데이터는 다시 복구할 수 없습니다.'),
          const SizedBox(
            height: 24.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              maxLines: 1,
              decoration: InputDecoration(
                  hintText: targetText, border: const OutlineInputBorder()),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) {
                value = value.toLowerCase();
                if (value == targetText.toLowerCase()) {
                  setState(() {
                    check = true;
                  });
                } else {
                  setState(() {
                    check = false;
                  });
                }
              },
              validator: (value) {
                value = value?.toLowerCase();
                if (value != targetText.toLowerCase()) {
                  return targetText;
                }
                return null;
              },
            ),
          )
        ],
      ),
      actions: [
        ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: check ? () => Navigator.of(context).pop(true) : null,
          child: const Text('확인'),
        ),
      ],
    );
  }
}

class _VerifiedText extends StatelessWidget {
  final bool verified;

  const _VerifiedText({super.key, required this.verified});

  @override
  Widget build(BuildContext context) {
    if (verified) {
      return const Row(
        children: [
          Text('인증 완료'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.verified,
              color: Colors.blue,
            ),
          ),
        ],
      );
    }
    return const Row(
      children: [
        Text('미인증'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.verified,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
