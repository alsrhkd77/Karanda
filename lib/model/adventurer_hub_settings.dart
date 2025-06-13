import 'package:karanda/enums/recruitment_category.dart';

class AdventurerHubSettings {
  bool notify;
  Set<RecruitmentCategory> excludedCategory = {};

  AdventurerHubSettings({this.notify = false, Set<RecruitmentCategory>? excludedCategory}) {
    this.excludedCategory.addAll(excludedCategory ?? {});
  }

  factory AdventurerHubSettings.fromJson(Map json) {
    final List<RecruitmentCategory> excludedCategoryList = [];
    for(String item in json["excludedCategory"] ?? []){
      excludedCategoryList.add(RecruitmentCategory.values.byName(item));
    }
    return AdventurerHubSettings(
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
