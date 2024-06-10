class BdoNewsModel{
  late String title;
  late String url;
  late String thumbnail;
  late String description;
  late String contentId;
  late DateTime added;

  BdoNewsModel.fromData(Map data){
    title = data['title'];
    url = data['url'];
    thumbnail = data['thumbnail'];
    description = data['description'];
    contentId = data['content_id'];
    added = DateTime.parse(data['added']);
  }
}