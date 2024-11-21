import 'package:karanda/auth/user.dart';
import 'package:karanda/common/enums/bdo_region.dart';
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
  late String recruitmentType;
  late int currentParticipants;
  late int maximumParticipants;
  String? content;
  String? discordLink;

  Recruitment({
    this.id,
    this.author,
    required this.region,
    required this.title,
    this.createdAt,
    required this.category,
    this.subcategory,
    required this.status,
    required this.recruitmentType,
    required this.currentParticipants,
    required this.maximumParticipants,
    this.content,
    this.discordLink,
  });

  Recruitment.fromData(Map data) {
    if (!data.containsKey("id") || !data.containsKey("createdAt") || !data.containsKey("author")){
      throw Exception("Invalid data - Recruitment");
    }
    author = data["author"]; //TODO: from data 필요
    id = data["id"];
    region = BdoRegion.values.byName(data["region"]);
    title = data["title"];
    createdAt = DateTime.parse(data["createdAt"]);
    category = RecruitmentCategory.values.byName(data["category"]);
    subcategory = data["subcategory"];
    status = data["status"];
    recruitmentType = data["recruitmentType"];
    currentParticipants = data["currentParticipants"];
    maximumParticipants = data["maximumParticipants"];
    content = data["content"];
    discordLink = data["discordLink"];
  }
}
