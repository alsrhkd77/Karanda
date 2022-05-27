import 'package:http/http.dart' as http;

class EventCrawler{

  Future<Map<String, DateTime>> getData() async {
    Map<String, DateTime> result = {};
    final response = await http.get(Uri.parse('https://raw.githubusercontent.com/HwanSangYeonHwa/black_event/main/events.json'));

    print(response.body);



    return result;
  }
}