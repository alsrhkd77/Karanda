import 'dart:convert';

class BdoNewsModel{
  late String title;
  late String url;
  late String thumbnail;
  late String description;
  late String contentId;
  late DateTime added;

  BdoNewsModel.fromJson(String json){
    Map data = jsonDecode(json);
    title = data['title'];
    url = data['url'];
    thumbnail = data['thumbnail'];
    description = data['description'];
    contentId = data['content_id'];
    added = DateTime.parse(data['added']);
  }
}