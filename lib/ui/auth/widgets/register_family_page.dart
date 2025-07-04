import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/ui/auth/widgets/family_verification_page.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator_dialog.dart';
import 'package:karanda/ui/core/ui/snack_bar_kit.dart';

class RegisterFamilyPage extends StatefulWidget {
  final Future<bool> Function({
  required String code,
  required String familyName,
  required BDORegion region,
  }) register;

  const RegisterFamilyPage({super.key, required this.register});

  @override
  State<RegisterFamilyPage> createState() => _RegisterFamilyPageState();
}

class _RegisterFamilyPageState extends State<RegisterFamilyPage> {
  final formKey = GlobalKey<FormState>();
  BDORegion region = BDORegion.KR;
  final familyNameTextController = TextEditingController();
  final profileURLTextController = TextEditingController();

  Future<void> submit() async {
    final code = parseUrl(profileURLTextController.text);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingIndicatorDialog(),
    );
    final result = await widget.register(
          region: region,
          code: code,
          familyName: familyNameTextController.text,
        );
    if (mounted) {
      context.pop();
      if (result) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const FamilyVerificationPage(),
          ),
        );
      } else {
        SnackBarKit.of(context).requestFailed();
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
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: KarandaAppBar(
        icon: Icons.add_task,
        title: context.tr("family.family"),
      ),
      body: Padding(
        padding: Dimens.constrainedPagePadding(width),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ListTile(
                title: Text(context.tr("region")),
                trailing: DropdownMenu(
                  initialSelection: region,
                  dropdownMenuEntries: BDORegion.values.map((value) {
                    return DropdownMenuEntry(value: value, label: value.name);
                  }).toList(),
                  onSelected: (value) {
                    if (value != null) {
                      setState(() {
                        region = value;
                      });
                    }
                  },
                ),
              ),
              TextFormField(
                controller: familyNameTextController,
                decoration: InputDecoration(
                  label: Text(context.tr("family.familyName")),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (String? value) {
                  if (value?.isEmpty ?? true) {
                    return context.tr(
                      "validator.fillWith",
                      args: [context.tr("family.familyName")],
                    );
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: profileURLTextController,
                decoration: InputDecoration(
                  label: Text(context.tr("family.adventurerProfileCode")),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (String? value) {
                  if (value?.isEmpty ?? true) {
                    return context.tr(
                      "validator.fillWith",
                      args: [context.tr("family.adventurerProfileCode")],
                    );
                  } else if (!value!.contains("profileTarget=") ||
                      !value.startsWith('https://')) {
                    return context.tr("validate.invalidFormat");
                  }
                  return null;
                },
              ),
              SizedBox(
                width: Size.infinite.width,
                child: ElevatedButton(
                  onPressed: () {
                    final formState = formKey.currentState!;
                    if (formState.validate()) {
                      submit();
                    }
                  },
                  child: const Text("Next →"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
