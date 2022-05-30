import 'package:flutter/material.dart';

class EventModel{
  String title;
  String count;
  DateTime deadline;
  String url;
  String thumbnail;
  Color color;

  EventModel(this.title, this.count, this.deadline, this.url, this.thumbnail, this.color);

  @override
  String toString() {
    return '$title ${deadline.toString()}';
  }
}