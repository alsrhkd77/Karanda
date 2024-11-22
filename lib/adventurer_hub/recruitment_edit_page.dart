import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/common/enums/bdo_region.dart';
import 'package:karanda/common/enums/recruit_method.dart';
import 'package:karanda/common/enums/recruitment_category.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator_dialog.dart';

class RecruitmentEditPage extends StatefulWidget {
  final Recruitment? recruitment;
  final RecruitmentCategory? category;

  const RecruitmentEditPage({super.key, this.recruitment, this.category});

  @override
  State<RecruitmentEditPage> createState() => _RecruitmentEditPageState();
}

class _RecruitmentEditPageState extends State<RecruitmentEditPage> {
  RecruitmentCategory category = RecruitmentCategory.values.first;
  RecruitMethod recruitMethod = RecruitMethod.values.first;
  late bool status = true;
  late bool showContentAfterJoin = true;

  final TextEditingController titleTextController = TextEditingController();
  final TextEditingController guildTextController = TextEditingController();
  final TextEditingController maximumTextController = TextEditingController();
  final TextEditingController contentTextController = TextEditingController();
  final TextEditingController discordTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    category = widget.category ?? category;
    if (widget.recruitment != null) {
      category = widget.recruitment!.category;
      recruitMethod = widget.recruitment!.recruitMethod;
      status = widget.recruitment!.status;
      showContentAfterJoin = widget.recruitment!.showContentAfterJoin ?? true;
      titleTextController.text = widget.recruitment!.title;
      if (category == RecruitmentCategory.guildRaidMercenaries) {
        guildTextController.text = widget.recruitment!.guildName!;
      }
      maximumTextController.text =
          widget.recruitment!.maximumParticipants.toString();
      contentTextController.text = widget.recruitment!.contents ?? "";
      discordTextController.text = widget.recruitment!.discordLink ?? "";
    }
    super.initState();
  }

  Future<void> submit(Recruitment recruitment) async {
    showDialog(
      context: context,
      builder: (context) => const LoadingIndicatorDialog(title: "Upload"),
    );

    await Future.delayed(Duration(seconds: 2));
    int statusCode = 200;

    if (context.mounted) Navigator.of(context).pop();
    if (statusCode == 200) {
      print("go detail page");
    } else if (statusCode == 401) {
      print("need login");
    } else {
      print("failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: context.tr("edit recruitment post"),
        icon: FontAwesomeIcons.circleNodes,
      ),
      body: Form(
        key: formKey,
        child: CustomBase(
          children: [
            ListTile(
              title: Text(
                  "${context.tr("adventurer hub category.${category.name}")} "
                  "${context.tr("recruitment")}"),
              trailing: const Text("KR"),
            ),
            const Divider(),
            const _NoteCard(),
            ListTile(
              title: TextFormField(
                maxLength: 40,
                maxLines: null,
                controller: titleTextController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  label: const Text("edit recruitment.title").tr(),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return context.tr("validate empty");
                  }
                  return null;
                },
              ),
            ),
            category == RecruitmentCategory.guildRaidMercenaries
                ? ListTile(
                    title: TextFormField(
                      controller: guildTextController,
                      maxLength: 32,
                      decoration: InputDecoration(
                        label: const Text("edit recruitment.guild name").tr(),
                        counterText: '',
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (category !=
                            RecruitmentCategory.guildRaidMercenaries) {
                          return null;
                        }
                        if (value?.isEmpty ?? true) {
                          return context.tr("validate empty");
                        }
                        return null;
                      },
                    ),
                  )
                : const SizedBox(),
            ListTile(
              title: TextFormField(
                controller: maximumTextController,
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,2})')),
                ],
                decoration: InputDecoration(
                  label: const Text("edit recruitment.number of recruits").tr(),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return context.tr("validate empty");
                  } else if (int.parse(value!) == 0) {
                    return context.tr("validate zero");
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              title: const Text("edit recruitment.recruit method").tr(),
              trailing: DropdownMenu<RecruitMethod>(
                enabled: widget.recruitment == null ? true : false,
                initialSelection: recruitMethod,
                dropdownMenuEntries: RecruitMethod.values.map((e) {
                  return DropdownMenuEntry(
                    value: e,
                    label: context.tr("recruit method.${e.name}"),
                  );
                }).toList(),
                onSelected: (value) {
                  if (value != null) {
                    setState(() {
                      recruitMethod = value;
                    });
                  }
                },
              ),
            ),
            ListTile(
              title: const Text("edit recruitment.start immediately").tr(),
              trailing: Checkbox(
                value: status,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
              ),
            ),
            recruitMethod == RecruitMethod.karandaReservation
                ? ListTile(
                    title: const Text(
                            "edit recruitment." "show contents after join")
                        .tr(),
                    trailing: Checkbox(
                      value: showContentAfterJoin,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            showContentAfterJoin = value;
                          });
                        }
                      },
                    ),
                  )
                : const SizedBox(),
            ListTile(
              title: const Text("edit recruitment.details").tr(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 18.0,
                right: 22.0,
                top: 4.0,
                bottom: 8.0,
              ),
              child: TextField(
                controller: contentTextController,
                maxLines: null,
                minLines: 12,
                maxLength: 1024,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  hintText: context.tr("edit recruitment.details hint"),
                ),
              ),
            ),
            ListTile(
              title: TextFormField(
                controller: discordTextController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (String? value) {
                  if (value == null ||
                      value.isEmpty ||
                      !value.contains('/') ||
                      value.startsWith('https://discord.gg/')) {
                    return null;
                  }
                  return context
                      .tr("edit recruitment.discord link validate failed");
                },
                decoration: InputDecoration(
                  label: const Text("edit recruitment.discord link").tr(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 20.0,
                top: 12.0,
                bottom: 8.0,
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    submit(Recruitment(
                      id: widget.recruitment?.id,
                      region: widget.recruitment?.region ?? BdoRegion.KR,
                      title: titleTextController.text,
                      category: category,
                      status: status,
                      recruitMethod:
                          widget.recruitment?.recruitMethod ?? recruitMethod,
                      currentParticipants:
                          widget.recruitment?.currentParticipants ?? 0,
                      maximumParticipants:
                          int.parse(maximumTextController.text),
                      contents: contentTextController.text,
                      discordLink: discordTextController.text,
                      guildName: guildTextController.text,
                      //서버에서 공백 제거하기
                      subcategory: widget.recruitment?.subcategory,
                      showContentAfterJoin:
                          (widget.recruitment?.recruitMethod ??
                                      recruitMethod) ==
                                  RecruitMethod.karandaReservation
                              ? showContentAfterJoin
                              : null,
                    ));
                  }
                },
                //icon: Icon(FontAwesomeIcons.penToSquare),
                icon: const Icon(FontAwesomeIcons.solidFloppyDisk),
                label: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 4.0,
                  ),
                  child: const Text("edit recruitment.save").tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        left: 18.0,
        right: 22.0,
        top: 8.0,
        bottom: 16.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                FontAwesomeIcons.triangleExclamation,
                color: Colors.red.shade300,
              ),
              title: const Text("edit recruitment.caution card title").tr(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: const Text("edit recruitment.caution card contents").tr(),
            ),
          ],
        ),
      ),
    );
  }
}

