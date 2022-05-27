import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

class EventCrawler{

  Future<Map<String, DateTime>> getData() async {
    Map<String, DateTime> result = {};
    final response = await http.get(Uri.parse('https://raw.githubusercontent.com/alsrhkd77/Maple-Timer/4637ffbb0e28f0a9f8f0877659ca54cf13961b8f/version.json'));

    print(response.body);

    dom.Document document = parser.parse(response.body);
    var data = document.getElementsByClassName('desc_area');


    return result;
  }
}