import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:web/web.dart' as web;

import '../app_controller.dart';
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
  var _watch = _Watch.package;
  var _channel = _Channel.discord;
  var _name = '';
  var _extra = '';
  var _suggestOpen = false;
  var _active = 0;
  var _fieldsOpen = false;
  final _ignored = <String>{};
  var _saving = false;
  var _signingIn = false;

  @override
  Component build(BuildContext context) {
    final controller = AppScope.of(context);
    if (controller.account == null) return _gate();

    return section(
      classes: 'page alerts',
      [
        Document.head(title: 'Alerts · pubstats'),
        h1([.text('Alerts')]),
        _editor(controller),
        if (controller.alertsFailed)
          div(
            classes: 'alert-empty panel',
            [
              p(classes: 'alert-empty-title', [.text('Unable to load alerts')]),
              p(classes: 'hint', [.text('Refresh the page to try again.')]),
            ],
          )
        else if (!controller.alertsLoaded)
          div(
            classes: 'alert-empty panel',
            attributes: {'role': 'status'},
            [
              const Spinner(),
              p(classes: 'hint', [.text('Loading alerts')]),
            ],
          )
        else if (controller.alerts.isEmpty)
          div(
            classes: 'alert-empty panel',
            [
              div(classes: 'alert-mark', [const Icon('notifications')]),
              div(
                classes: 'alert-empty-copy',
                [
                  p(classes: 'alert-empty-title', [.text('No alerts yet')]),
                  p(classes: 'hint', [.text('Add a package, publisher, or scan above.')]),
                ],
              ),
            ],
          )
        else
          _list(controller),
      ],
    );
  }

  Component _gate() {
    return section(
      classes: 'page alerts gate',
      [
        Document.head(title: 'Alerts · pubstats'),
        div(classes: 'alert-mark', [const Icon('notifications')]),
        div(
          classes: 'alert-head',
          [
            h1([.text('Alerts')]),
            p(
              classes: 'alert-lead',
              [
                .text(
                  'Sign in with Google to get Discord or Telegram messages when a package, a publisher, or a scan changes.',
                ),
              ],
            ),
          ],
        ),
        button(
          classes: 'elevated action-btn${_signingIn ? ' is-saving' : ''}',
          type: ButtonType.button,
          disabled: _signingIn,
          onClick: _signingIn ? null : () => unawaited(_signIn()),
          [if (_signingIn) const Spinner() else .text('Sign in with Google')],
        ),
      ],
    );
  }

  Component _editor(AppController controller) {
    final typed = _name.trim().toLowerCase();
    final matches = _watch == _Watch.package && _suggestOpen && typed.isNotEmpty
        ? [
            for (final name in controller.complete(_name))
              if (name != typed) name,
          ]
        : const <String>[];
    final active = matches.isEmpty ? 0 : _active.clamp(0, matches.length - 1);
    final extraError = _extraError;
    final fieldsMissing = _watch != _Watch.system && _ignored.length >= packageFields.length;
    final label = _watch == _Watch.publisher ? 'Publisher name' : 'Package name';

    return form(
      classes: 'composer panel',
      noValidate: true,
      events: {
        'submit': (event) {
          event.preventDefault();
          unawaited(_add());
        },
      },
      [
        div(
          classes: 'composer-block',
          [
            span(classes: 'field-label', [.text('Watch')]),
            div(
              classes: 'spans',
              attributes: {'role': 'group', 'aria-label': 'What to watch'},
              [
                for (final watch in _Watch.values)
                  button(
                    classes: _watch == watch ? 'span active' : 'span',
                    type: ButtonType.button,
                    attributes: {'aria-pressed': '${_watch == watch}'},
                    onClick: () => _setWatch(watch),
                    [.text(watch.label)],
                  ),
              ],
            ),
            if (_watch == _Watch.system)
              p(classes: 'hint', [.text('When a scan finishes, and when a scan fails.')])
            else ...[
              _nameField(label, matches, active),
              if (_watch == _Watch.publisher)
                p(
                  classes: _nameError == null ? 'hint' : 'hint error',
                  [.text(_nameError ?? 'Every package from this publisher.')],
                ),
            ],
          ],
        ),
        div(
          classes: 'composer-block',
          [
            span(classes: 'field-label', [.text('Send to')]),
            div(
              classes: 'spans',
              attributes: {'role': 'group', 'aria-label': 'Where to send alerts'},
              [
                for (final channel in _Channel.values)
                  button(
                    classes: _channel == channel ? 'span active' : 'span',
                    type: ButtonType.button,
                    attributes: {'aria-pressed': '${_channel == channel}'},
                    onClick: () => _setChannel(channel),
                    [.text(channel.label)],
                  ),
              ],
            ),
            input(
              classes: 'field',
              type: InputType.text,
              value: _extra,
              attributes: {
                'placeholder': _channel.placeholder,
                'aria-label': _channel.inputLabel,
                'autocomplete': 'off',
                'autocapitalize': 'off',
                'spellcheck': 'false',
              },
              onInput: (String value) => setState(() => _extra = value),
            ),
            p(
              classes: extraError == null ? 'hint' : 'hint error',
              [.text(extraError ?? _channel.hint)],
            ),
          ],
        ),
        if (_watch != _Watch.system)
          div(
            classes: 'composer-block',
            [
              span(classes: 'field-label', [.text('Notify for')]),
              button(
                classes: _fieldsOpen ? 'disclosure open' : 'disclosure',
                type: ButtonType.button,
                attributes: {'aria-expanded': '$_fieldsOpen'},
                onClick: () => setState(() => _fieldsOpen = !_fieldsOpen),
                [
                  span(classes: 'disclosure-label', [.text(_fieldSummary(_ignored))]),
                  Icon(_fieldsOpen ? 'expand_less' : 'expand_more'),
                ],
              ),
              if (_fieldsOpen)
                div(
                  classes: 'field-chips',
                  [
                    for (final field in packageFields)
                      button(
                        classes: _ignored.contains(field) ? 'choice' : 'choice on',
                        type: ButtonType.button,
                        attributes: {'aria-pressed': '${!_ignored.contains(field)}'},
                        onClick: () => setState(() {
                          if (_ignored.contains(field)) {
                            _ignored.remove(field);
                          } else {
                            _ignored.add(field);
                          }
                        }),
                        [.text(_fieldLabel(field))],
                      ),
                  ],
                ),
              if (fieldsMissing) p(classes: 'hint error', [.text('Choose at least one change')]),
            ],
          ),
        div(
          classes: 'composer-actions',
          [
            button(
              classes: 'elevated action-btn${_saving ? ' is-saving' : ''}',
              type: ButtonType.submit,
              disabled: !_canSave || !controller.alertsLoaded || controller.alertsFailed,
              [if (_saving) const Spinner() else .text('Add alert')],
            ),
          ],
        ),
      ],
    );
  }

  Component _nameField(String label, List<String> matches, int active) {
    return div(
      classes: 'slug-box',
      [
        input(
          classes: 'field',
          type: InputType.text,
          value: _name,
          attributes: {
            'placeholder': _watch == _Watch.publisher ? 'dart.dev' : label,
            'aria-label': label,
            'autocomplete': 'off',
            'autocapitalize': 'off',
            'spellcheck': 'false',
            if (_watch == _Watch.package) ...{
              'aria-autocomplete': 'list',
              'aria-expanded': '${matches.isNotEmpty}',
              'aria-controls': 'package-suggestions',
            },
          },
          onInput: (String value) => setState(() {
            _name = value;
            _suggestOpen = _watch == _Watch.package;
            _active = 0;
          }),
          events: {
            'focus': (_) => setState(() => _suggestOpen = _watch == _Watch.package),
            'blur': (_) {
              Future.delayed(const Duration(milliseconds: 160), () {
                if (mounted) setState(() => _suggestOpen = false);
              });
            },
            'keydown': (event) {
              if (_watch != _Watch.package) return;
              final key = event as web.KeyboardEvent;
              switch (key.key) {
                case 'ArrowDown':
                  key.preventDefault();
                  if (matches.isEmpty) return;
                  setState(() => _active = (active + 1) % matches.length);
                case 'ArrowUp':
                  key.preventDefault();
                  if (matches.isEmpty) return;
                  setState(() => _active = (active - 1 + matches.length) % matches.length);
                case 'Enter':
                  if (!_suggestOpen || matches.isEmpty) return;
                  key.preventDefault();
                  _pick(matches[active]);
                case 'Escape':
                  if (!_suggestOpen) return;
                  key.preventDefault();
                  setState(() => _suggestOpen = false);
              }
            },
          },
        ),
        if (matches.isNotEmpty)
          div(
            id: 'package-suggestions',
            classes: 'suggestions',
            attributes: {'role': 'listbox'},
            [
              for (var i = 0; i < matches.length; i++)
                button(
                  classes: i == active ? 'suggestion active' : 'suggestion',
                  type: ButtonType.button,
                  attributes: {'role': 'option', 'aria-selected': '${i == active}'},
                  events: {'mousedown': (event) => event.preventDefault()},
                  onClick: () => _pick(matches[i]),
                  [.text(matches[i])],
                ),
            ],
          ),
      ],
    );
  }

  Component _list(AppController controller) {
    final count = controller.alerts.length;
    return div(
      classes: 'alert-list panel',
      attributes: {'aria-label': '$count ${count == 1 ? 'alert' : 'alerts'}'},
      [
        for (var i = count - 1; i >= 0; i--) _row(controller, i),
      ],
    );
  }

  Component _row(AppController controller, int index) {
    final alert = controller.alerts[index];
    final target = _targetOf(alert.slug);
    final destination = _destination(alert);
    final detail = alert.slug == '.system' ? 'Each scan' : _fieldSummary(alert.ignore);
    return div(
      classes: 'alert-row',
      [
        div(
          classes: 'alert-copy',
          [
            div(
              classes: 'alert-title',
              [
                if (target.linked)
                  Link(to: '/packages/${target.name}', classes: 'alert-name', child: .text(target.name))
                else
                  span(classes: 'alert-name', [.text(target.name)]),
                span(classes: 'pill', [.text(target.kind)]),
              ],
            ),
            span(
              classes: 'alert-meta',
              attributes: {'title': destination},
              [.text(destination)],
            ),
            span(classes: 'alert-meta', [.text(detail)]),
          ],
        ),
        button(
          classes: 'icon-btn',
          type: ButtonType.button,
          attributes: {'aria-label': 'Delete ${target.name} alert'},
          onClick: () => unawaited(controller.removeAlert(index)),
          [const Icon('delete')],
        ),
      ],
    );
  }

  Future<void> _signIn() async {
    setState(() => _signingIn = true);
    await AppScope.of(context).signIn();
    if (mounted) setState(() => _signingIn = false);
  }

  void _setWatch(_Watch watch) {
    if (watch == _watch) return;
    setState(() {
      _watch = watch;
      _suggestOpen = false;
      _active = 0;
    });
  }

  void _setChannel(_Channel channel) {
    if (channel == _channel) return;
    setState(() {
      _channel = channel;
      _extra = '';
    });
  }

  void _pick(String name) {
    setState(() {
      _name = name;
      _suggestOpen = false;
      _active = 0;
    });
  }

  String get _slugName {
    var name = _name.trim().toLowerCase();
    if (_watch == _Watch.publisher && name.startsWith('publisher:')) {
      name = name.substring('publisher:'.length).trim();
    }
    return name;
  }

  String get _slug => switch (_watch) {
    _Watch.package => _slugName,
    _Watch.publisher => 'publisher:$_slugName',
    _Watch.system => '.system',
  };

  String? get _extraError {
    final extra = _extra.trim();
    if (extra.isEmpty) return null;
    return switch (_channel) {
      _Channel.discord => isDiscordWebhook(extra) ? null : 'Paste a discord.com/api/webhooks URL',
      _Channel.telegram => isTelegramChatId(extra) ? null : 'Use a numeric chat ID, like -1001234567890',
    };
  }

  String? get _nameError {
    if (_watch != _Watch.publisher) return null;
    final name = _slugName;
    if (name.isEmpty || isPublisherId(name)) return null;
    return 'Enter a publisher, like dart.dev';
  }

  bool get _canSave {
    if (_saving) return false;
    if (_watch != _Watch.system && _slugName.isEmpty) return false;
    if (_nameError != null) return false;
    if (_extra.trim().isEmpty || _extraError != null) return false;
    if (_watch != _Watch.system && _ignored.length >= packageFields.length) return false;
    return true;
  }

  Future<void> _add() async {
    final controller = AppScope.of(context);
    if (!_canSave || !controller.alertsLoaded || controller.alertsFailed) return;
    setState(() => _saving = true);
    var added = false;
    try {
      added = await controller.addAlert(
        slug: _slug,
        type: _channel.name,
        extra: _extra,
        ignore: _watch == _Watch.system ? const {} : Set.of(_ignored),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (!added) return;
        _name = '';
        _extra = '';
        _suggestOpen = false;
        _active = 0;
      });
    }
  }
}

enum _Watch {
  package('Package'),
  publisher('Publisher'),
  system('System');

  const _Watch(this.label);

  final String label;
}

enum _Channel {
  discord(
    'Discord',
    'Webhook URL',
    'https://discord.com/api/webhooks/…',
    'Channel settings → Integrations → Webhooks → Copy Webhook URL.',
  ),
  telegram(
    'Telegram',
    'Chat ID',
    'Chat ID',
    'Add @pubstats_bot to the chat, then paste the chat ID.',
  );

  const _Channel(this.label, this.inputLabel, this.placeholder, this.hint);

  final String label;
  final String inputLabel;
  final String placeholder;
  final String hint;
}

({String kind, String name, bool linked}) _targetOf(String slug) {
  if (slug == '.system') return (kind: 'System', name: 'Scanner', linked: false);
  const prefix = 'publisher:';
  if (slug.startsWith(prefix)) {
    final name = slug.substring(prefix.length);
    return (kind: 'Publisher', name: name.isEmpty ? slug : name, linked: false);
  }
  return (kind: 'Package', name: slug, linked: true);
}

String _destination(AlertConfig alert) => switch (alert) {
  DiscordAlert(:final id) => 'Discord webhook · $id',
  TelegramAlert(:final chatId) => 'Telegram chat · $chatId',
};

String _fieldLabel(String field) => switch (field) {
  'likeCount' => 'Likes',
  'popularityScore' => 'Popularity',
  'downloadCount' => 'Downloads',
  'isDiscontinued' => 'Discontinued',
  'isUnlisted' => 'Unlisted',
  'isFlutterFavorite' => 'Flutter Favorite',
  'pubPoints' => 'Pub points',
  _ => titleCase(field),
};

String _fieldSummary(Set<String> ignore) {
  final skipped = [
    for (final field in packageFields)
      if (ignore.contains(field)) _fieldLabel(field),
  ];
  final watched = packageFields.length - skipped.length;
  if (watched == 0) return 'Nothing selected';
  if (skipped.isEmpty) return 'All changes';
  if (skipped.length <= 2) return 'Skipping ${skipped.join(' and ')}';
  if (watched <= 3) {
    return [
      for (final field in packageFields)
        if (!ignore.contains(field)) _fieldLabel(field),
    ].join(', ');
  }
  return '$watched changes';
}
