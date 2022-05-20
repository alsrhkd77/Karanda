import 'package:black_tools/settings/settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }
  
  Widget singleBox(String name){
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: Container(
                margin: EdgeInsets.all(12.0),
                child: Icon(Icons.ac_unit, size: 55.0),
              ),
            ),
            Text(name),
          ],
        ),
      ),
      onTap: (){},
    );
  }

  List<Widget> buildMenu(){
    List<Widget> result = [];
    for(int i=0;i<12;i++){
      Widget widget = singleBox('app${i+1}');
      result.add(widget);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Flutter Demo Home Page'),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.settings))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            ListTile(
              title: Text('생활'),
              trailing: ChangeNotifierProvider.value(
                  value: SettingsNotifier(),
                child: Switch(
                  value: Provider.of<SettingsNotifier>(context).darkMode,
                  onChanged: (value){
                    Provider.of<SettingsNotifier>(context, listen: false).setDarkMode(value);
                  },
                ),
              ),
            ),
            Divider(),
            Wrap(
              runSpacing: 20.0,
              spacing: 20.0,
              children: buildMenu(),
            ),
            SizedBox(height: 12.0,),
            ListTile(
              title: Text('아토락시온'),
            ),
            Divider(),
            Wrap(
              runSpacing: 20.0,
              spacing: 20.0,
              children: buildMenu(),
            ),
          ],
        ),
      ),
    );
  }
}
