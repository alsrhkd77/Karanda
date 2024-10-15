import 'package:flutter/material.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/verification_center/widgets/main_family_chip.dart';
import 'package:karanda/widgets/class_symbol_widget.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';

class FamilyVerificationPage extends StatefulWidget {
  const FamilyVerificationPage({super.key});

  @override
  State<FamilyVerificationPage> createState() => _FamilyVerificationPageState();
}

class _FamilyVerificationPageState extends State<FamilyVerificationPage> {
  final TextStyle leadingStyle = const TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: GlobalProperties.scrollViewPadding,
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.add_task),
                title: TitleText(
                  "가문 인증 정보",
                  bold: true,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: GlobalProperties.widthConstrains,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Text(
                        '가문명:',
                        style: leadingStyle,
                      ),
                      title: Row(
                        children: [Text('하라쿤타'), MainFamilyChip()],
                      ),
                    ),
                    ListTile(
                      leading: Text(
                        '가문 생성일:',
                        style: leadingStyle,
                      ),
                      title: Text(DateTime.now().format('yyyy.MM.dd')),
                    ),
                    ListTile(
                      leading: Text(
                        '대표 클래스:',
                        style: leadingStyle,
                      ),
                      title: Row(
                        children: [
                          Text('커세어'),
                          ClassSymbolWidget(className: 'corsair')
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Text(
                        '인증 상태:',
                        style: leadingStyle,
                      ),
                      title: Text('인증 완료'),
                    ),
                    ListTile(
                      leading: Text(
                        '인증 시작:',
                        style: leadingStyle,
                      ),
                      title: Text(DateTime.now().format(null)),
                    ),
                    ListTile(
                      leading: Text(
                        '1단계 인증:',
                        style: leadingStyle,
                      ),
                      title: Text(DateTime.now().format(null)),
                    ),
                    ListTile(
                      leading: Text(
                        '2단계 인증:',
                        style: leadingStyle,
                      ),
                      title: Text(DateTime.now().format(null)),
                    ),
                    Container(
                      width: Size.infinite.width,
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('갱신하기'),
                        ),
                      ),
                    ),
                    Container(
                      width: Size.infinite.width,
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('메인 가문으로 설정'),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text('인증 카드 발급'),
        icon: Icon(Icons.add_card),
      ),*/
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(context: context, builder: (context) => _VerificationDialog());
        },
        label: Text('인증 진행'),
        icon: Icon(Icons.fact_check_outlined),
      ),
    );
  }
}

class _VerificationDialog extends StatefulWidget {
  const _VerificationDialog({super.key});

  @override
  State<_VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<_VerificationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('가문 인증'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: "모험가 프로필의 "),
                TextSpan(text: "생활 레벨", style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: " 공개 여부\n변경 후 확인 버튼을 눌러주세요!"),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15,),
          Text('1단계 인증: 공개 → 비공개'),
          Text('2단계 인증: 비공개 → 공개'),
        ],
      ),
      contentPadding: const EdgeInsets.all(24.0),
      actions: [ElevatedButton(onPressed: (){}, child: Text("확인"))],
    );
  }
}
