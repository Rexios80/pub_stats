import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../app_scope.dart';
import '../components/widgets.dart';
import '../format.dart';
import '../models.dart';

class AlertsPage extends StatefulComponent {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  var _slug = '';
  var _extra = '';
  var _type = 'discord';
  var _focused = false;
  var _fieldsOpen = false;
  final _ignored = <String>{};
  var _saving = false;

  @override
  Component build(BuildContext context) {
    final controller = AppScope.of(context);
    if (controller.account == null) {
      return section(
        classes: 'page alerts gate',
        [
          Document.head(title: 'Alerts · pubstats'),
          h1([.text('Alerts Manager')]),
          p(
            classes: 'muted',
            [.text('Sign in with Google to manage Discord and Telegram alerts.')],
          ),
          button(
            classes: 'elevated',
            type: ButtonType.button,
            onClick: () => unawaited(controller.signIn()),
            [.text('Sign in with Google')],
          ),
        ],
      );
    }

    return section(
      classes: 'page alerts',
      [
        Document.head(title: 'Alerts · pubstats'),
        h1([.text('Alerts Manager')]),
        div(
          classes: 'alert-form panel',
          [
            div(
              classes: 'slug-box',
              [
                input(
                  classes: 'field',
                  type: InputType.text,
                  value: _slug,
                  attributes: {'placeholder': 'Alert slug', 'aria-label': 'Alert slug'},
                  onInput: (String value) => setState(() => _slug = value),
                  events: {
                    'focus': (_) => setState(() => _focused = true),
                    'blur': (_) {
                      Future.delayed(const Duration(milliseconds: 160), () {
                        if (mounted) setState(() => _focused = false);
                      });
                    },
                  },
                ),
                if (_focused)
                  div(
                    classes: 'suggestions hint-list',
                    [
                      div([.text('".system" for system alerts')]),
                      div([.text('"packageName" for single package alerts')]),
                      div([.text('"publisher:publisherName" for publisher package alerts')]),
                    ],
                  ),
              ],
            ),
            select(
              value: _type,
              attributes: {'aria-label': 'Alert type'},
              onChange: (List<String> values) => setState(() => _type = values.first),
              [
                option(
                  value: 'discord',
                  selected: _type == 'discord',
                  [.text('Discord')],
                ),
                option(
                  value: 'telegram',
                  selected: _type == 'telegram',
                  [.text('Telegram')],
                ),
              ],
            ),
            input(
              classes: 'field',
              type: InputType.text,
              value: _extra,
              attributes: {
                'placeholder': _type == 'telegram' ? 'Chat ID' : 'Webhook URL',
                'aria-label': _type == 'telegram' ? 'Chat ID' : 'Webhook URL',
              },
              onInput: (String value) => setState(() => _extra = value),
            ),
            div(
              classes: 'popover',
              [
                button(
                  classes: 'icon-btn',
                  type: ButtonType.button,
                  attributes: {'aria-label': 'Alert fields', 'title': 'Alert fields'},
                  onClick: () => setState(() => _fieldsOpen = !_fieldsOpen),
                  [Icon(_fieldIcon(_ignored))],
                ),
                if (_fieldsOpen) ...[
                  div(
                    classes: 'menu-scrim',
                    events: {'click': (_) => setState(() => _fieldsOpen = false)},
                    [],
                  ),
                  div(
                    classes: 'menu checks',
                    [
                      for (final field in packageFields)
                        label(
                          classes: 'check-row',
                          [
                            input(
                              type: InputType.checkbox,
                              checked: !_ignored.contains(field),
                              onChange: (bool checked) {
                                setState(() {
                                  if (checked) {
                                    _ignored.remove(field);
                                  } else {
                                    _ignored.add(field);
                                  }
                                });
                              },
                            ),
                            .text(titleCase(field)),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
            button(
              classes: 'icon-btn',
              type: ButtonType.button,
              attributes: {'aria-label': 'Add alert'},
              onClick: _saving ? null : () => unawaited(_add()),
              [const Icon('add')],
            ),
          ],
        ),
        if (_type == 'telegram')
          p(
            classes: 'alert-note muted',
            [.text('Add the pubstats_bot user to your chat')],
          ),
        div(
          classes: 'table-wrap panel',
          [
            table(
              classes: 'alert-table',
              [
                thead([
                  tr([
                    th([.text('Slug')]),
                    th([.text('Type')]),
                    th([.text('Extra')]),
                    th([.text('Fields')]),
                    th([.text('Actions')]),
                  ]),
                ]),
                tbody([
                  if (controller.alerts.isEmpty)
                    tr([
                      td(
                        colspan: 5,
                        [.text('No alerts yet')],
                      ),
                    ])
                  else
                    for (var i = 0; i < controller.alerts.length; i++)
                      tr([
                        td([.text(controller.alerts[i].slug)]),
                        td([.text(titleCase(controller.alerts[i].type))]),
                        td(
                          classes: 'clip',
                          attributes: {'title': controller.alerts[i].extra},
                          [.text(controller.alerts[i].extra)],
                        ),
                        td([Icon(_fieldIcon(controller.alerts[i].ignore))]),
                        td([
                          button(
                            classes: 'icon-btn',
                            type: ButtonType.button,
                            attributes: {'aria-label': 'Delete alert'},
                            onClick: () => unawaited(controller.removeAlert(i)),
                            [const Icon('delete')],
                          ),
                        ]),
                      ]),
                ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _add() async {
    setState(() => _saving = true);
    final added = await AppScope.of(
      context,
    ).addAlert(slug: _slug, type: _type, extra: _extra, ignore: Set.of(_ignored));
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (added) _slug = '';
    });
  }
}

String _fieldIcon(Set<String> ignored) {
  if (ignored.length >= packageFields.length) return 'notifications_off';
  if (ignored.isNotEmpty) return 'notifications_none';
  return 'notifications';
}
