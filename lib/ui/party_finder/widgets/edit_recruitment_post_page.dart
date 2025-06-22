import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/enums/recruitment_type.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator_dialog.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:karanda/ui/core/ui/snack_bar_kit.dart';
import 'package:provider/provider.dart';

import '../controllers/edit_recruitment_post_controller.dart';

class EditRecruitmentPostPage extends StatelessWidget {
  final Recruitment? recruitment;
  final BDORegion region;

  const EditRecruitmentPostPage({
    super.key,
    this.recruitment,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditRecruitmentPostController(
        partyFinderRepository: context.read(),
        region: region,
        recruitment: recruitment,
      ),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.circleNodes,
          title: context.tr("partyFinder.editPost.editPost"),
        ),
        body: Consumer(
          builder: (context, EditRecruitmentPostController controller, child) {
            return Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                padding: Dimens.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: Dimens.pageMaxWidth,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: TextFormField(
                            decoration: InputDecoration(
                              labelText:
                                  context.tr("partyFinder.editPost.title"),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: controller.titleTextController,
                            maxLength: 60,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return context.tr("validator.empty");
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            context.tr("partyFinder.editPost.category"),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 24.0,
                          ),
                          trailing: DropdownMenu(
                            initialSelection: controller.category,
                            enabled: recruitment == null,
                            dropdownMenuEntries:
                                RecruitmentCategory.values.map((value) {
                              return DropdownMenuEntry(
                                value: value,
                                label: context.tr(
                                  "partyFinder.category.${value.name}",
                                ),
                              );
                            }).toList(),
                            onSelected: controller.setCategory,
                          ),
                        ),
                        ListTile(
                          title: Text(
                            context
                                .tr("partyFinder.editPost.recruitmentType"),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 24.0,
                          ),
                          trailing: DropdownMenu(
                            initialSelection: controller.recruitmentType,
                            enabled: recruitment == null,
                            dropdownMenuEntries:
                                RecruitmentType.values.map((value) {
                              return DropdownMenuEntry(
                                value: value,
                                label: context.tr(
                                  "partyFinder.recruitmentType.${value.name}",
                                ),
                              );
                            }).toList(),
                            onSelected: controller.setRecruitmentType,
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            decoration: InputDecoration(
                              labelText:
                                  context.tr("partyFinder.editPost.slots"),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: controller.slotTextController,
                            keyboardType: const TextInputType.numberWithOptions(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^(\d{1,3})'),
                              ),
                            ],
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return context.tr("validator.empty");
                              } else if (int.parse(value!) == 0) {
                                return context.tr("validator.zero");
                              }
                              return null;
                            },
                          ),
                        ),
                        _GuildName(
                          category: controller.category,
                          textEditingController:
                              controller.guildNameTextController,
                        ),
                        Section(
                          title: context.tr("partyFinder.editPost.content"),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              maxLines: null,
                              minLines: 12,
                              maxLength: 1000,
                              controller: controller.contentTextController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 12.0,
                                ),
                                hintText: context.tr(
                                  "partyFinder.editPost.contentHint",
                                ),
                              ),
                            ),
                          ),
                        ),
                        Section(
                          title: context.tr(
                            "partyFinder.editPost.privateContent",
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              enabled: controller.recruitmentType ==
                                  RecruitmentType.karandaReservation,
                              maxLines: null,
                              minLines: 12,
                              maxLength: 1000,
                              controller: controller.privateContentTextController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 12.0,
                                ),
                                hintText: context.tr(
                                  "partyFinder.editPost.privateContentHint",
                                ),
                              ),
                            ),
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            decoration: InputDecoration(
                              labelText: context
                                  .tr("partyFinder.editPost.discordLink"),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: controller.discordTextController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[1-9A-Za-z:/-\\.]+'),
                              ),
                            ],
                            validator: (String? value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('/') ||
                                  value.startsWith('https://discord.gg/')) {
                                return null;
                              }
                              return context.tr(
                                "partyFinder.editPost.discordLinkValidateFailed",
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: _SubmitButton(isCreatePost: recruitment == null),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final bool isCreatePost;

  const _SubmitButton({super.key, required this.isCreatePost});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  Future<void> submit() async {
    final controller = context.read<EditRecruitmentPostController>();
    if (controller.validate) {
      showDialog(
        context: context,
        builder: (context) => const LoadingIndicatorDialog(),
      );
      final result = widget.isCreatePost
          ? await controller.create()
          : await controller.update();
      if (mounted) {
        Navigator.of(context).pop();
        if (result != null) {
          Navigator.of(context).pop(result);
        } else {
          SnackBarKit.of(context).requestFailed();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Size.infinite.width,
      child: ElevatedButton.icon(
        onPressed: submit,
        icon: const Icon(FontAwesomeIcons.solidFloppyDisk),
        label: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 4.0,
          ),
          child: Text(context.tr("partyFinder.editPost.save")),
        ),
      ),
    );
  }
}

class _GuildName extends StatelessWidget {
  final RecruitmentCategory category;
  final TextEditingController textEditingController;

  const _GuildName({
    super.key,
    required this.category,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    if (category == RecruitmentCategory.guildBossRaid ||
        category == RecruitmentCategory.guildWar) {
      return ListTile(
        title: TextFormField(
          controller: textEditingController,
          decoration: InputDecoration(
              labelText: context.tr("partyFinder.editPost.guildName"),
              counter: const SizedBox()),
          maxLength: 32,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (category != RecruitmentCategory.guildBossRaid &&
                category != RecruitmentCategory.guildWar) {
              return null;
            }
            if (value?.isEmpty ?? true) {
              return context.tr("validator.empty");
            }
            return null;
          },
        ),
      );
    }
    return const SizedBox();
  }
}
