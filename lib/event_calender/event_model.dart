class EventModel{
  String title;
  String count;
  DateTime deadline;
  String url;
  String thumbnail;

  EventModel(this.title, this.count, this.deadline, this.url, this.thumbnail);

  @override
  String toString() {
    return '$title ${deadline.toString()}';
  }
}