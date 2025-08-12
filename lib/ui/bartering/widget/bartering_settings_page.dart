import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/model/bartering/bartering_mastery.dart';
import 'package:karanda/model/bartering/ship_profile.dart';
import 'package:karanda/repository/bartering_repository.dart';
import 'package:karanda/ui/bartering/controller/bartering_settings_controller.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:provider/provider.dart';

class BarteringSettingsPage extends StatelessWidget {
  final BarteringRepository repository;

  const BarteringSettingsPage({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: repository),
        ChangeNotifierProvider(
          create: (context) => BarteringSettingsController(
            repository: context.read(),
          ),
        ),
      ],
      builder: (context, child) {
        return Scaffold(
          appBar: KarandaAppBar(
            title: context.tr("bartering.bartering"),
            icon: FontAwesomeIcons.arrowRightArrowLeft,
          ),
          body: Consumer(
            builder: (context, BarteringSettingsController controller, child) {
              if (controller.settings == null || controller.mastery.isEmpty) {
                return LoadingIndicator();
              }
              return PageBase(
                children: [
                  Section(
                    title: context.tr("bartering.settings.commons"),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(context.tr("bartering.settings.mastery")),
                          trailing: DropdownMenu<BarteringMastery>(
                            initialSelection:
                                controller.mastery.firstWhere((item) {
                              return item.isSame(controller.settings!.mastery);
                            }),
                            dropdownMenuEntries: controller.mastery.map((item) {
                              final rank =
                                  context.tr("lifeSkillLevel.${item.rank}");
                              return DropdownMenuEntry(
                                value: item,
                                label: "$rank ${item.level}",
                              );
                            }).toList(),
                            onSelected: controller.onMasterySelected,
                            inputDecorationTheme: InputDecorationTheme(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        CheckboxListTile(
                          value: controller.settings?.valuePack,
                          onChanged: controller.useValuePack,
                          title: Text(
                            context.tr("bartering.settings.valuePack"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Section(
                    title: context.tr("bartering.settings.shipProfiles"),
                    child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.settings!.shipProfiles.length + 1,
                      itemBuilder: (context, index) {
                        if (index == controller.settings!.shipProfiles.length) {
                          return ListTile(
                            leading: Icon(Icons.add),
                            title: Text(
                              context.tr("bartering.settings.addProfile"),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => _ShipProfile(
                                  data: ShipProfile(),
                                  onSave: controller.addShipProfile,
                                ),
                              );
                            },
                          );
                        }
                        final item = controller.settings!.shipProfiles[index];
                        return ListTile(
                          title: Text(item.name),
                          trailing: IconButton(
                            onPressed: () {
                              controller.removeShipProfile(index);
                            },
                            icon: Icon(Icons.close, color: Colors.red),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => _ShipProfile(
                                data: item,
                                onSave: (value) {
                                  return controller.updateShipProfile(
                                    index: index,
                                    shipProfile: value,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ShipProfile extends StatefulWidget {
  final ShipProfile data;
  final bool Function(ShipProfile) onSave;

  const _ShipProfile({super.key, required this.data, required this.onSave});

  @override
  State<_ShipProfile> createState() => _ShipProfileState();
}

class _ShipProfileState extends State<_ShipProfile> {
  final formKey = GlobalKey<FormState>();
  final nameTextController = TextEditingController();
  final totalWeightController = TextEditingController();
  final currentWeightController = TextEditingController();
  late bool useCleia;
  bool duplicated = false;

  @override
  void initState() {
    useCleia = widget.data.useCleia;
    nameTextController.text = widget.data.name;
    totalWeightController.text = widget.data.totalWeight.toStringAsFixed(2);
    currentWeightController.text = widget.data.currentWeight.toStringAsFixed(2);
    super.initState();
  }

  void save() {
    if (formKey.currentState?.validate() ?? false) {
      final totalWeight = double.tryParse(totalWeightController.text) ?? 0;
      final currentWeight = double.tryParse(currentWeightController.text) ?? 0;
      final result = widget.onSave(ShipProfile(
        name: nameTextController.text,
        totalWeight: totalWeight,
        currentWeight: currentWeight,
        useCleia: useCleia,
      ));
      if (result) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          duplicated = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr("bartering.settings.shipProfiles")),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 460),
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12.0,
            children: [
              TextFormField(
                controller: nameTextController,
                maxLines: 1,
                maxLength: 48,
                decoration: InputDecoration(
                  labelText: context.tr("bartering.settings.profileName"),
                  counter: const SizedBox(),
                  errorText: duplicated
                      ? context.tr("bartering.settings.duplicated")
                      : null,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return context.tr("validator.empty");
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    duplicated = false;
                  });
                },
              ),
              TextFormField(
                controller: currentWeightController,
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9.]*$')),
                ],
                maxLength: 12,
                decoration: InputDecoration(
                  labelText: context.tr("bartering.settings.currentWeight"),
                  counter: const SizedBox(),
                  suffixText: "LT",
                ),
              ),
              TextFormField(
                controller: totalWeightController,
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9.]*$')),
                ],
                maxLength: 12,
                decoration: InputDecoration(
                  labelText: context.tr("bartering.settings.maxWeight"),
                  counter: const SizedBox(),
                  suffixText: "LT",
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return context.tr("validator.zero");
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: Text(context.tr("bartering.settings.cleia")),
                value: useCleia,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      useCleia = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr("cancel")),
        ),
        ElevatedButton(
          onPressed: save,
          child: Text(context.tr("bartering.settings.save")),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
