import 'package:flutter/material.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/verification_center/family_verification_page.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';

class StartFamilyVerificationPage extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final familyNameTextController = TextEditingController();
  final profileURLTextController = TextEditingController();

  StartFamilyVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ListTile(
                leading: Icon(Icons.add_task),
                title: TitleText(
                  '가문 등록', // =Family verification
                  bold: true,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                constraints: BoxConstraints(
                  maxWidth: GlobalProperties.widthConstrains,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      enabled: false,
                      decoration: const InputDecoration(label: Text('서버')),
                      initialValue: 'KR',
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: familyNameTextController,
                      decoration: const InputDecoration(label: Text('가문명')),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) return '가문명을 입력해주세요';
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: profileURLTextController,
                      decoration:
                          const InputDecoration(label: Text('모험가 프로필 URL')),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return '모험가 프로필 URL을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: Size.infinite.width,
                constraints: BoxConstraints(
                  maxWidth: GlobalProperties.widthConstrains,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.indigoAccent),
                  onPressed: () {
                    final formState = formKey.currentState!;
                    if (formState.validate()) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FamilyVerificationPage(),
                        ),
                      );
                      print("send");
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TitleText('Next →'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
