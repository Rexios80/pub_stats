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
                  IconButton(
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

  void addConfig() async {
    final slug = slugController.text;
    final extra = extraController.text;

    if (slug.isEmpty || extra.isEmpty) return;

    if (!await _user.validateSlug(slug)) {
      return;
    }

    await _user.addConfig(
      DiscordConfig(
        slug: slug,
        type: selectedType.value,
        webhookUrl: extraController.text,
      ),
    );

    slugController.clear();
    extraController.clear();
  }
}
