import 'package:karanda/auth/user.dart';
import 'package:karanda/common/enums/bdo_region.dart';
import 'package:karanda/common/enums/recruit_method.dart';
import 'package:karanda/common/enums/recruitment_category.dart';

class Recruitment {
  int? id;
  User? author;
  late BdoRegion region;
  late String title;
  DateTime? createdAt;
  late RecruitmentCategory category;
  String? subcategory;
  late bool status;
  late RecruitMethod recruitMethod;
  late int currentParticipants;
  late int maximumParticipants;
  String? guildName;
  String? content;
  String? discordLink;
  bool? showContentAfterJoin;
  bool blinded = false;

  Recruitment({
    this.id,
    this.author,
    required this.region,
    required this.title,
    this.createdAt,
    required this.category,
    this.subcategory,
    required this.status, //모집중 = true, 모집중아님 = false
    required this.recruitMethod,
    required this.currentParticipants,
    required this.maximumParticipants,
    this.guildName,
    this.content,
    this.discordLink,
    this.showContentAfterJoin,
  });

  Recruitment.fromData(Map data) {
    if (!data.containsKey("id") || !data.containsKey("createdAt") || !data.containsKey("author")){
      throw Exception("Invalid data - Recruitment");
    }
    author = User.fromData(data["author"]);
    id = data["id"];
    region = BdoRegion.values.byName(data["region"]);
    title = data["title"];
    createdAt = DateTime.parse(data["createdAt"]);
    category = RecruitmentCategory.values.byName(data["category"]);
    subcategory = data["subcategory"];
    status = data["status"];
    recruitMethod = RecruitMethod.values.byName(data["recruitMethod"]);
    currentParticipants = data["currentParticipants"];
    maximumParticipants = data["maximumParticipants"];
    guildName = data["guildName"];
    content = data["content"];
    discordLink = data["discordLink"];
    showContentAfterJoin = data["showContentAfterJoin"];
    blinded = data["blinded"];
  }

  Map toData(){
    Map data = {};
    data['id'] = id;
    data['author'] = author;
    data['region'] = region.name;
    data['title'] = title;
    data['category'] = category.name;
    data['subcategory'] = subcategory;
    data['status'] = status;
    data['recruitMethod'] = recruitMethod.name;
    data['currentParticipants'] = currentParticipants;
    data['maximumParticipants'] = maximumParticipants;
    data['guildName'] = guildName;
    data['content'] = content;
    data['discordLink'] = discordLink;
    data['showContentAfterJoin'] = showContentAfterJoin;
    return data;
  }
}
