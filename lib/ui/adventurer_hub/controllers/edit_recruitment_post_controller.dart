import 'package:flutter/widgets.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/enums/recruitment_type.dart';
import 'package:karanda/repository/adventurer_hub_repository.dart';

import '../../../model/recruitment.dart';

class EditRecruitmentPostController extends ChangeNotifier {
  final AdventurerHubRepository _adventurerHubRepository;
  final BDORegion region;
  final formKey = GlobalKey<FormState>();
  final titleTextController = TextEditingController();
  final guildNameTextController = TextEditingController();
  final slotTextController = TextEditingController();
  final contentTextController = TextEditingController();
  final privateContentTextController = TextEditingController();
  final discordTextController = TextEditingController();

  Recruitment? recruitment;
  late RecruitmentCategory category;
  late RecruitmentType recruitmentType;

  EditRecruitmentPostController({
    required AdventurerHubRepository adventurerHubRepository,
    required this.region,
    this.recruitment,
  }) : _adventurerHubRepository = adventurerHubRepository {
    if (recruitment == null) {
      category = RecruitmentCategory.values.first;
      recruitmentType = RecruitmentType.values.first;
    } else {
      category = recruitment!.category;
      recruitmentType = recruitment!.recruitmentType;
      titleTextController.text = recruitment!.title;
      guildNameTextController.text = recruitment!.guildName;
      slotTextController.text = recruitment!.maxMembers.toString();
      contentTextController.text = recruitment!.content;
      privateContentTextController.text = recruitment!.privateContent;
      discordTextController.text = recruitment!.discordLink ?? "";
    }
  }

  bool get validate => formKey.currentState?.validate() ?? false;

  Future<Recruitment?> update() async {
    if (recruitment != null && validate) {
      recruitment!
        ..title = titleTextController.text
        ..maxMembers = int.parse(slotTextController.text)
        ..guildName = category == RecruitmentCategory.guildWar ||
                category == RecruitmentCategory.guildBossRaid
            ? guildNameTextController.text
            : ""
        ..content = contentTextController.text
        ..privateContent = privateContentTextController.text
        ..discordLink = discordTextController.text.isEmpty
            ? null
            : discordTextController.text;
      return await _adventurerHubRepository.updatePost(recruitment!);
    }
    return null;
  }

  Future<Recruitment?> create() async {
    if (validate) {
      final post = RecruitmentPost(
        region: region,
        title: titleTextController.text,
        category: category,
        recruitmentType: recruitmentType,
        maxMembers: int.parse(slotTextController.text),
        guildName: category == RecruitmentCategory.guildWar ||
                category == RecruitmentCategory.guildBossRaid
            ? guildNameTextController.text
            : "",
        specLimit: null,
        content: contentTextController.text,
        privateContent: privateContentTextController.text,
        discordLink: discordTextController.text.isEmpty
            ? null
            : discordTextController.text,
      );
      return await _adventurerHubRepository.createPost(post);
    }
    return null;
  }

  void setCategory(RecruitmentCategory? value) {
    if (value != null) {
      category = value;
      notifyListeners();
    }
  }

  void setRecruitmentType(RecruitmentType? value) {
    if (value != null) {
      recruitmentType = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleTextController.dispose();
    guildNameTextController.dispose();
    slotTextController.dispose();
    contentTextController.dispose();
    privateContentTextController.dispose();
    discordTextController.dispose();
    super.dispose();
  }
}
