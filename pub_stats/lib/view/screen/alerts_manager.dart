import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/user_controller.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:recase/recase.dart';

class AlertsManager extends StatelessWidget {
  static final _user = GetIt.I<UserController>();

  final selectedType = AlertType.discord.rx;
  final slugController = TextEditingController();
  final extraController = TextEditingController();
  final ignoredFields = <PackageDataField>{}.rx;

  final selectedConfigs = <AlertConfig>{}.rx;

  AlertsManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts Manager'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TypeAheadField(
                      suggestionsCallback: (pattern) => [
                        '".system" for system alerts',
                        '"packageName" for single package alerts',
                        '"publisher:publisherName" for publisher package alerts',
                      ],
                      itemBuilder: (context, suggestion) =>
                          ListTile(title: Text(suggestion)),
                      onSuggestionSelected: (suggestion) {},
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: slugController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Alert slug',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: FastBuilder(
                      () => DropdownButtonFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        value: selectedType.value,
                        items: AlertType.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name.titleCase),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          selectedType.value = value;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FastBuilder(
                      () => TextField(
                        controller: extraController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: selectedType.value.extraLabel,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  PopupMenuButton(
                    tooltip: 'Alert fields',
                    itemBuilder: (context) => PackageDataField.values
                        .map(
                          (e) => PopupMenuItem(
                            child: FastBuilder(
                              () => CheckboxListTile(
                                value: !ignoredFields.contains(e),
                                onChanged: (value) {
                                  if (value == true) {
                                    ignoredFields.remove(e);
                                  } else {
                                    ignoredFields.add(e);
                                  }
                                },
                                title: Text(e.name.titleCase),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    child: FastBuilder(() {
                      final IconData icon;
                      if (ignoredEverything) {
                        icon = Icons.notifications_off_outlined;
                      } else if (ignoredFields.isNotEmpty) {
                        icon = Icons.notifications_outlined;
                      } else {
                        icon = Icons.notifications;
                      }
                      return Icon(icon);
                    }),
                  ),
                  IconButton(
                    tooltip: 'Add alert',
                    icon: const Icon(Icons.add),
                    onPressed: addConfig,
                  ),
                ],
              ),
            ),
            Expanded(
              child: FastBuilder(
                () => DataTable(
                  columns: const [
                    DataColumn(label: Text('Slug')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Extra')),
                  ],
                  rows: _user.configs
                      .map(
                        (e) => DataRow(
                          selected: selectedConfigs.contains(e),
                          onSelectChanged: (value) {
                            if (value == true) {
                              selectedConfigs.add(e);
                            } else {
                              selectedConfigs.remove(e);
                            }
                          },
                          cells: [
                            DataCell(Text(e.slug)),
                            DataCell(Text(e.type.name.titleCase)),
                            DataCell(Text(e.extra)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get ignoredEverything =>
      PackageDataField.values.toSet().difference(ignoredFields).isEmpty;

  void addConfig() async {
    final slug = slugController.text;
    final extra = extraController.text;

    if (slug.isEmpty || extra.isEmpty || ignoredEverything) {
      return;
    }

    if (!await _user.validateSlug(slug)) {
      return;
    }

    await _user.addConfig(
      DiscordConfig(
        slug: slug,
        ignore: ignoredFields,
        type: selectedType.value,
        webhookUrl: extraController.text,
      ),
    );

    slugController.clear();
    extraController.clear();
  }
}
