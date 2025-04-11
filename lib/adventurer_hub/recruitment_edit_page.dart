import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/common/enums/bdo_region.dart';
import 'package:karanda/common/enums/recruit_method.dart';
import 'package:karanda/common/enums/recruitment_category.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/utils/rest_client.dart';
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
  late bool status = false;
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
      if (category == RecruitmentCategory.guildWarHeroes) {
        guildTextController.text = widget.recruitment!.guildName!;
      }
      maximumTextController.text =
          widget.recruitment!.maximumParticipants.toString();
      contentTextController.text = widget.recruitment!.content ?? "";
      discordTextController.text = widget.recruitment!.discordLink ?? "";
    }
    super.initState();
  }

  Future<void> submit(Recruitment recruitment) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingIndicatorDialog(title: "Upload"),
    );
    if (widget.recruitment == null) {
      int? postId = await create(recruitment);
      if (mounted) {
        Navigator.of(context).pop();
        if (postId != null) {
          context.replaceNamed('/adventurer-hub');
          context.goWithGa('/adventurer-hub/posts/$postId');
        }
      }
    } else {
      Recruitment? result = await update(recruitment);
      if(mounted){
        Navigator.of(context).pop();
        if(result != null){
          context.pop(result);
        }
      }
    }

  }

  Future<int?> create(Recruitment recruitment) async {
    int? postId;
    final response = await RestClient.post(
      "adventurer-hub/post/create",
      body: jsonEncode(recruitment.toData()),
      json: true,
    );

    if (response.statusCode == 201) {
      postId = int.parse(response.body);
    }
    return postId;
  }

  Future<Recruitment?> update(Recruitment recruitment) async {
    Recruitment? result;
    final response = await RestClient.patch(
      "adventurer-hub/post/update",
      body: jsonEncode(recruitment.toData()),
      json: true,
    );

    if (response.statusCode == 200) {
      result = Recruitment.fromData(jsonDecode(response.bodyUTF));
    }
    return result;
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
                  label: Text(context.tr("edit recruitment.title")),
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
            category == RecruitmentCategory.guildWarHeroes
                ? ListTile(
                    title: TextFormField(
                      enabled: widget.recruitment == null,
                      controller: guildTextController,
                      maxLength: 32,
                      decoration: InputDecoration(
                        label: Text(context.tr("edit recruitment.guild name")),
                        counterText: '',
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (category != RecruitmentCategory.guildWarHeroes) {
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
                  label:
                      Text(context.tr("edit recruitment.number of recruits")),
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
              title: Text(context.tr("edit recruitment.recruit method")),
              trailing: DropdownMenu<RecruitMethod>(
                enabled: widget.recruitment == null,
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
            /*ListTile(
              title: Text(context.tr("edit recruitment.start immediately")),
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
            ),*/
            recruitMethod == RecruitMethod.karandaReservation
                ? ListTile(
                    title: Text(context
                        .tr("edit recruitment.show contents after join")),
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
              title: Text(context.tr("edit recruitment.details")),
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
                maxLength: 1000,
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
                  return context
                      .tr("edit recruitment.discord code validate failed");
                },
                decoration: InputDecoration(
                  label: Text(context.tr("edit recruitment.discord code")),
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
                      content: contentTextController.text.trim(),
                      discordLink: discordTextController.text,
                      guildName: guildTextController.text,
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
                icon: const Icon(FontAwesomeIcons.solidFloppyDisk),
                label: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 4.0,
                  ),
                  child: Text(context.tr("edit recruitment.save")),
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
                color: Colors.red.shade600,
              ),
              title: Text(context.tr("edit recruitment.caution card title")),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Text(context.tr("edit recruitment.caution card contents")),
            ),
          ],
        ),
      ),
    );
  }
}
