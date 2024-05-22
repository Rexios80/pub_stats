import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/user_controller.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:recase/recase.dart';

class AlertsManager extends StatelessWidget {
  static final _user = GetIt.I<UserController>();

  final selectedType = AlertConfigType.discord.rx;
  final slugController = SearchController();
  final extraController = TextEditingController();
  final ignoredFields = <PackageDataField>{}.rx;

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
                    child: SearchAnchor.bar(
                      suggestionsBuilder: (context, controller) => [
                        Text('".system" for system alerts'),
                        Text('"packageName" for single package alerts'),
                        Text(
                            '"publisher:publisherName" for publisher package alerts'),
                      ],
                      searchController: slugController,
                      barHintText: 'Alert slug',
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
                        items: AlertConfigType.values
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
                    child: FastBuilder(
                      () => AlertFieldsButton(
                        ignoredFields: ignoredFields..register(),
                      ),
                    ),
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
              child: SingleChildScrollView(
                child: FastBuilder(
                  () => DataTable(
                    columns: const [
                      DataColumn(label: Text('Slug')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Extra')),
                      DataColumn(label: Text('Fields')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _user.configs
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(Text(e.slug)),
                              DataCell(Text(e.type.name.titleCase)),
                              DataCell(
                                SizedBox(
                                  width: 200,
                                  child: Text(e.extra),
                                ),
                              ),
                              DataCell(
                                PopupMenuButton(
                                  tooltip: 'Alert fields',
                                  itemBuilder: (context) =>
                                      enabledFields(e.ignore)
                                          .map(
                                            (e) => PopupMenuItem(
                                              child: Text(e.name.titleCase),
                                            ),
                                          )
                                          .toList(),
                                  child: AlertFieldsButton(
                                    ignoredFields: e.ignore,
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _user.removeConfig(e),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addConfig() async {
    if (!await _user.addConfig(
      slug: slugController.text,
      ignore: ignoredFields,
      type: selectedType.value,
      extra: extraController.text,
    )) return;

    slugController.clear();
    extraController.clear();
  }
}

class AlertFieldsButton extends StatelessWidget {
  final Set<PackageDataField> ignoredFields;

  const AlertFieldsButton({
    super.key,
    required this.ignoredFields,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    if (enabledFields(ignoredFields).isEmpty) {
      icon = Icons.notifications_off_outlined;
    } else if (ignoredFields.isNotEmpty) {
      icon = Icons.notifications_outlined;
    } else {
      icon = Icons.notifications;
    }
    return Icon(icon);
  }
}
