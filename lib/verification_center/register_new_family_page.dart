import 'package:flutter/material.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/verification_center/family_verification_page.dart';
import 'package:karanda/verification_center/models/bdo_family.dart';
import 'package:karanda/verification_center/verification_center_data_controller.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator_dialog.dart';
import 'package:karanda/widgets/title_text.dart';

class RegisterNewFamilyPage extends StatelessWidget {
  final VerificationCenterDataController dataController;
  final formKey = GlobalKey<FormState>();
  final familyNameTextController = TextEditingController();
  final profileURLTextController = TextEditingController();

  RegisterNewFamilyPage({super.key, required this.dataController});

  Future<void> submit(BuildContext context) async {
    String region = "KR";
    String code = parseUrl(profileURLTextController.text);
    String familyName = familyNameTextController.text;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingIndicatorDialog(),
    );
    BdoFamily? result = await dataController.register(region, code, familyName);
    if (context.mounted) {
      Navigator.of(context).pop();
      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FamilyVerificationPage(
              dataController: dataController,
              familyData: result,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 8.0,
                ),
                Text("가문 등록에 실패했습니다."),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: GlobalProperties.snackBarMargin,
          ),
        );
      }
    }
  }

  String parseUrl(String url) {
    String result = '';
    for (String item in url.split('&')) {
      if (item.contains('profileTarget=')) {
        result = item.split('profileTarget=').last;
        break;
      }
    }
    return result;
  }

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
                        } else if (!value!.contains("profileTarget=") ||
                            !value.startsWith('https://')) {
                          return '올바르지 않은 형식입니다';
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
                  onPressed: () {
                    final formState = formKey.currentState!;
                    if (formState.validate()) {
                      submit(context);
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
