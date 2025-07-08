import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/ui/auth/controllers/family_verification_controller.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/snack_bar_kit.dart';
import 'package:karanda/widgets/loading_indicator_dialog.dart';
import 'package:provider/provider.dart';

class FamilyVerificationPage extends StatefulWidget {
  const FamilyVerificationPage({super.key});

  @override
  State<FamilyVerificationPage> createState() => _FamilyVerificationPageState();
}

class _FamilyVerificationPageState extends State<FamilyVerificationPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  Future<void> process(Future<bool> Function() func) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingIndicatorDialog(),
    );
    final result = await func();
    if (mounted) {
      Navigator.of(context).pop();
      if (result) {
        goNextPage();
      } else {
        SnackBarKit.of(context).requestFailed();
      }
    }
  }

  void goNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FamilyVerificationController(
          authRepository: context.read(), timeRepository: context.read()),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: Icons.how_to_reg_outlined,
          title: context.tr("family.verification"),
        ),
        body: Consumer(
          builder: (context, FamilyVerificationController controller, child) {
            return PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step(
                  title: context.tr("family.readyForVerification"),
                  detail: context.tr("family.startVerificationHint"),
                  buttonText: context.tr("family.startVerification"),
                  onPressed: () => process(controller.startVerification),
                ),
                _Step(
                  title: "Step 1",
                  detail: context.tr(
                    "family.${controller.locked ? "needUnlock" : "needLock"}",
                  ),
                  buttonText: context.tr("family.verify"),
                  timeLimit: controller.timeLimit,
                  onPressed: controller.timeLimit?.isNegative ?? false
                      ? null
                      : () => process(controller.verify),
                ),
                _Step(
                  title: "Step 2",
                  detail: context.tr(
                    "family.${controller.locked ? "needLock" : "needUnlock"}",
                  ),
                  buttonText: context.tr("family.verify"),
                  timeLimit: controller.timeLimit,
                  onPressed: controller.timeLimit?.isNegative ?? false
                      ? null
                      : () => process(controller.verify),
                ),
                _Step(
                  title: "Complete the verification process",
                  detail: "👏 Family verification completed successfully.",
                  buttonText: "Finish",
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String title;
  final String detail;
  final String buttonText;
  final void Function()? onPressed;
  final Duration? timeLimit;

  const _Step({
    super.key,
    required this.title,
    required this.detail,
    required this.buttonText,
    required this.onPressed,
    this.timeLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: Dimens.pageMaxWidth),
      padding: Dimens.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          timeLimit == null ? const SizedBox() : _TimeLimit(value: timeLimit!),
          Text(
            title,
            style: TextTheme.of(context).titleLarge,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                detail,
                style: TextTheme.of(context).bodyLarge,
              ),
            ),
          ),
          Container(
            width: Size.infinite.width,
            constraints: const BoxConstraints(maxWidth: Dimens.pageMaxWidth),
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeLimit extends StatelessWidget {
  final Duration value;

  const _TimeLimit({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "timeLimitChip",
      child: Chip(
        label: value.isNegative
            ? const Text("00:00")
            : Text(
                "${value.inMinutes.toString().padLeft(2, "0")}:${(value.inSeconds % 60).toString().padLeft(2, "0")}"),
        avatar: const Icon(Icons.timer_outlined),
      ),
    );
  }
}
