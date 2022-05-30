import 'dart:convert';

import 'package:black_tools/event_calender/event_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EventCalenderController extends GetxController{

  Future<List<EventModel>> getData() async {
    List<EventModel> result = [];
    final response = await http.get(Uri.parse('https://raw.githubusercontent.com/HwanSangYeonHwa/black_event/main/events.json'));

    List data = jsonDecode(response.body)['events'];

    for(Map e in data){
      String title = e['title'];
      String count = e['count'];
      String url = e['url'];
      String thumbnail = e['thumbnail'];
      DateTime deadline = DateTime(1996, 11, 12);
      if(!count.contains('상시')){
        deadline = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        deadline = deadline.add(Duration(days: int.parse(count.split(' ')[0])));
      }
      result.add(EventModel(title.replaceAll('[이벤트]', '').trim(), count, deadline, url, thumbnail));
    }
    print(result);

    return result;
  }
}