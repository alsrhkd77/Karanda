import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/custom_scroll_behavior.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_data_controller.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_material.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ShipUpgradingPage extends StatefulWidget {
  const ShipUpgradingPage({super.key});

  @override
  State<ShipUpgradingPage> createState() => _ShipUpgradingPageState();
}

class _ShipUpgradingPageState extends State<ShipUpgradingPage> {
  final ShipUpgradingDataController dataController =
      ShipUpgradingDataController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ready());
  }

  Future<void> ready() async {
    bool result = await dataController.getBaseData();
    if (result) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(FontAwesomeIcons.ship),
                title: TitleText(
                  '선박 증축',
                  bold: true,
                ),
              ),
            ),
            loading
                ? const LoadingIndicator()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _Head(dataController: dataController),
                  ),
            _Body(dataStream: dataController.materials),
          ],
        ),
      ),
    );
  }
}

class _Head extends StatelessWidget {
  final ShipUpgradingDataController dataController;

  const _Head({super.key, required this.dataController});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: GlobalProperties.widthConstrains,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _ShipTypeSelector(dataController: dataController),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _PercentInHeader(),
          ),
        ],
      ),
    );
  }
}

class _ShipTypeSelector extends StatelessWidget {
  final ShipUpgradingDataController dataController;

  const _ShipTypeSelector({super.key, required this.dataController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dataController.selectedShip,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            DropdownMenu<String>(
              initialSelection: snapshot.data?.nameEN,
              dropdownMenuEntries: dataController.ship.keys
                  .map<DropdownMenuEntry<String>>(
                    (e) => DropdownMenuEntry(
                      value: dataController.ship[e]!.nameEN,
                      label: dataController.ship[e]!.nameKR,
                    ),
                  )
                  .toList(),
              onSelected: (String? value) {
                if (value != null) {
                  dataController.updateSelected(value);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _PercentInHeader extends StatelessWidget {
  const _PercentInHeader({super.key});

  MaterialColor getColor(double percent) {
    if (percent < 0.25) {
      return Colors.red;
    } else if (percent < 0.5) {
      return Colors.orange;
    } else if (percent < 0.75) {
      return Colors.yellow;
    } else if (percent < 1) {
      return Colors.green;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    double percent = 0.4983;
    return Flex(
      direction: Axis.horizontal,
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: LinearPercentIndicator(
            animation: true,
            animationDuration: 500,
            percent: percent,
            barRadius: const Radius.circular(4.0),
            progressColor: getColor(percent),
            animateFromLastPercent: true,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          "${(percent * 100).toStringAsFixed(2)}%",
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final Stream<Map<String, ShipUpgradingMaterial>> dataStream;
  const _Body({super.key, required this.dataStream});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: GlobalProperties.widthConstrains,
            minWidth: 480,
          ),
          child: StreamBuilder(
            stream: dataStream,
            builder: (context, snapshot){
              if(!snapshot.hasData){
                return const LoadingIndicator();
              }
              return LoadingIndicator();
            },
          ),
        ),
      ),
    );
  }
}
