import 'package:karanda/enums/recruitment_category.dart';

class PartyFinderSettings {
  bool notify;
  Set<RecruitmentCategory> excludedCategory = {};

  PartyFinderSettings({this.notify = false, Set<RecruitmentCategory>? excludedCategory}) {
    this.excludedCategory.addAll(excludedCategory ?? {});
  }

  factory PartyFinderSettings.fromJson(Map json) {
    final List<RecruitmentCategory> excludedCategoryList = [];
    for(String item in json["excludedCategory"] ?? []){
      excludedCategoryList.add(RecruitmentCategory.values.byName(item));
    }
    return PartyFinderSettings(
      notify: json["notify"],
      excludedCategory: Set.from(excludedCategoryList),
    );
  }

  Map toJson(){
    return {
      "notify": notify,
      "excludedCategory": excludedCategory.map((item) => item.name).toList(),
    };
  }
}
