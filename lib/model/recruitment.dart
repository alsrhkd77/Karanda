import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/enums/recruitment_type.dart';
import 'package:karanda/model/user.dart';

class Recruitment extends RecruitmentPost {
  final int id;
  final User author;
  final bool status;
  final int currentParticipants;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool blinded;

  //final List<Applicants> applicants;

  Recruitment({
    this.id = 0,
    required this.author,
    required super.region,
    super.title,
    required super.category,
    this.status = false,
    required super.recruitmentType,
    this.currentParticipants = 0,
    required super.maxMembers,
    super.guildName,
    super.specLimit,
    super.content,
    super.privateContent,
    super.discordLink,
    required this.createdAt,
    this.updatedAt,
    this.blinded = false,
  });

  factory Recruitment.fromJson(Map json) {
    return Recruitment(
      id: json["id"],
      author: User.fromJson(json["author"]),
      region: BDORegion.values.byName(json["region"]),
      title: json["title"],
      category: RecruitmentCategory.values.byName(json["category"]),
      status: json["status"],
      recruitmentType: RecruitmentType.values.byName(json["recruitmentType"]),
      currentParticipants: json["currentParticipants"] ?? 0,
      maxMembers: json["maxMembers"],
      guildName: json["guildName"] ?? "",
      specLimit: json["specLimit"],
      content: json["content"] ?? "",
      privateContent: json["privateContent"] ?? "",
      discordLink: json["discordLink"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      blinded: json["blinded"] ?? false,
    );
  }

  @override
  Map toJson() {
    return {
      "id": id,
      "author": author.toJson(),
      "region": region.name,
      "title": title,
      "category": category.name,
      "status": status,
      "recruitmentType": recruitmentType.name,
      "currentParticipants": currentParticipants,
      "maxMembers": maxMembers,
      "guildName": guildName,
      "specLimit": specLimit,
      "content": content,
      "privateContent": privateContent,
      "discordLink": discordLink,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "blinded": blinded,
    };
  }

  void updateFromSimplified(Recruitment data){

  }
}

class RecruitmentPost {
  final BDORegion region;
  String title;
  RecruitmentCategory category;
  RecruitmentType recruitmentType;
  int maxMembers;
  String guildName;
  int? specLimit;
  String content;
  String privateContent;
  String? discordLink;

  RecruitmentPost({
    required this.region,
    this.title = "",
    required this.category,
    required this.recruitmentType,
    required this.maxMembers,
    this.guildName = "",
    this.specLimit,
    this.content = "",
    this.privateContent = "",
    this.discordLink,
  });

  Map toJson() {
    return {
      "region": region.name,
      "title": title,
      "category": category.name,
      "recruitmentType": recruitmentType.name,
      "maxMembers": maxMembers,
      "guildName": guildName,
      "specLimit": specLimit,
      "content": content,
      "privateContent": privateContent,
      "discordLink": discordLink,
    };
  }
}
