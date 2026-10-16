import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:web/web.dart' as web;

import '../app_controller.dart';
import '../app_scope.dart';
import '../models.dart';
import 'widgets.dart';

class Shell extends StatefulComponent {
  const Shell({required this.controller, required this.child, super.key});

  final AppController controller;
  final Component child;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  var _stuck = false;
  StreamSubscription<web.Event>? _scroll;
  StreamSubscription<web.KeyboardEvent>? _keys;

  @override
  void initState() {
    super.initState();
    component.controller.addListener(_changed);
    _scroll = web.EventStreamProviders.scrollEvent.forTarget(web.window).listen((_) {
      final stuck = web.window.scrollY > 24;
      if (stuck != _stuck && mounted) setState(() => _stuck = stuck);
    });
    _keys = web.EventStreamProviders.keyDownEvent.forTarget(web.window).listen((event) {
      if (event.key == 'Escape') component.controller.closeDialog();
    });
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    component.controller.removeListener(_changed);
    unawaited(_scroll?.cancel());
    unawaited(_keys?.cancel());
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final controller = component.controller;
    final onAlerts = RouteState.maybeOf(context)?.location.startsWith('/alerts') ?? false;
    return AppScope(
      controller: controller,
      revision: controller.revision,
      child: div(
        classes: 'app',
        [
          const TopBar(),
          if (!onAlerts) Tools(stuck: _stuck),
          main_([component.child]),
          const FooterBar(),
          if (controller.snackbar case final snack?) SnackBar(message: snack),
          if (controller.popularityInfo || controller.licensesOpen || controller.packageDialog != null)
            const DialogLayer(),
        ],
      ),
    );
  }
}

class TopBar extends StatelessComponent {
  const TopBar({super.key});

  @override
  Component build(BuildContext context) {
    final controller = AppScope.of(context);
    final onAlerts = RouteState.maybeOf(context)?.location.startsWith('/alerts') ?? false;
    return header(
      classes: 'top',
      [
        div(
          classes: 'top-bar',
          [
            const Link(
              to: '/',
              classes: 'brand',
              children: [
                img(src: 'images/logo.svg', alt: '', width: 75, height: 71),
                span([.text('pubstats')]),
              ],
            ),
            div(
              classes: 'actions',
              [
                button(
                  classes: 'icon-btn',
                  type: ButtonType.button,
                  attributes: {'aria-label': 'Toggle theme'},
                  onClick: controller.cycleTheme,
                  [
                    Icon(switch (controller.theme) {
                      ThemePreference.system => 'brightness_auto',
                      ThemePreference.dark => 'brightness_4',
                      ThemePreference.light => 'brightness_7',
                    }),
                  ],
                ),
                if (controller.account case final account?) ...[
                  if (!onAlerts)
                    div(
                      classes: 'wide-only',
                      [
                        button(
                          classes: 'elevated',
                          type: ButtonType.button,
                          onClick: () => context.push('/alerts'),
                          [.text('Manage Alerts')],
                        ),
                      ],
                    ),
                  MenuButton(
                    icon: 'person',
                    label: 'Account menu',
                    child: account.photoUrl == null || account.photoUrl!.isEmpty
                        ? const Icon('person')
                        : img(src: account.photoUrl!, alt: account.name ?? 'Account'),
                    items: [('Sign out', () => unawaited(controller.signOut()))],
                  ),
                ] else ...[
                  if (!onAlerts)
                    div(
                      classes: 'wide-only',
                      [
                        button(
                          classes: 'elevated',
                          type: ButtonType.button,
                          onClick: () => unawaited(_signIn(context)),
                          [.text('Manage Alerts')],
                        ),
                      ],
                    ),
                  if (!onAlerts)
                    div(
                      classes: 'narrow-only',
                      [
                        MenuButton(
                          icon: 'more_vert',
                          label: 'More',
                          items: [('Manage Alerts', () => unawaited(_signIn(context)))],
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _signIn(BuildContext context) async {
  final controller = AppScope.of(context);
  final signedIn = controller.account != null || await controller.signIn();
  if (signedIn) context.push('/alerts');
}

class Tools extends StatefulComponent {
  const Tools({required this.stuck, super.key});

  final bool stuck;

  @override
  State<Tools> createState() => _ToolsState();
}

class _ToolsState extends State<Tools> {
  var _query = '';
  var _open = false;
  var _active = 0;

  @override
  Component build(BuildContext context) {
    final controller = AppScope.of(context);
    final typed = _query.trim();
    final suggestions = typed.isEmpty
        ? const <String>[]
        : <String>[
            typed,
            for (final name in controller.complete(typed))
              if (name != typed) name,
          ];
    final active = suggestions.isEmpty ? 0 : _active.clamp(0, suggestions.length - 1);
    return div(
      classes: component.stuck ? 'tools stuck' : 'tools',
      [
        div(
          classes: 'search',
          [
            form(
              events: {
                'submit': (event) {
                  event.preventDefault();
                  _openPackage(typed);
                },
              },
              [
                div(
                  classes: 'search-bar',
                  [
                    if (controller.loading) const Spinner() else const Icon('search'),
                    input(
                      type: InputType.search,
                      value: _query,
                      attributes: {
                        'placeholder': 'Enter a package name',
                        'aria-label': 'Package name',
                        'autocomplete': 'off',
                      },
                      onInput: (String value) => setState(() {
                        _query = value;
                        _open = true;
                        _active = 0;
                      }),
                      events: {
                        'focus': (_) => setState(() => _open = true),
                        'blur': (_) {
                          Future.delayed(const Duration(milliseconds: 160), () {
                            if (mounted) setState(() => _open = false);
                          });
                        },
                        'keydown': (event) {
                          final key = event as web.KeyboardEvent;
                          switch (key.key) {
                            case 'ArrowDown':
                              key.preventDefault();
                              if (suggestions.isEmpty) return;
                              setState(() {
                                _open = true;
                                _active = (active + 1) % suggestions.length;
                              });
                            case 'ArrowUp':
                              key.preventDefault();
                              if (suggestions.isEmpty) return;
                              setState(() {
                                _open = true;
                                _active = (active - 1 + suggestions.length) % suggestions.length;
                              });
                            case 'Enter':
                              if (!_open || suggestions.isEmpty) return;
                              key.preventDefault();
                              _openPackage(suggestions[active]);
                            case 'Escape':
                              setState(() => _open = false);
                          }
                        },
                      },
                    ),
                    button(
                      classes: 'icon-btn',
                      type: ButtonType.button,
                      attributes: {'aria-label': 'Feeling lucky?'},
                      onClick: () {
                        final package = controller.randomPackage();
                        if (package != null) context.push('/packages/$package');
                      },
                      [const Icon('casino')],
                    ),
                  ],
                ),
              ],
            ),
            if (_open && suggestions.isNotEmpty)
              div(
                classes: 'suggestions',
                attributes: {'role': 'listbox'},
                [
                  for (var i = 0; i < suggestions.length; i++)
                    div(
                      classes: i == active ? 'suggestion active' : 'suggestion',
                      attributes: {'role': 'option', 'aria-selected': '${i == active}'},
                      [
                        button(
                          type: ButtonType.button,
                          events: {'mousedown': (event) => event.preventDefault()},
                          onClick: () => _openPackage(suggestions[i]),
                          [.text(suggestions[i])],
                        ),
                        if (_currentPackages(context).isNotEmpty)
                          button(
                            classes: 'compare',
                            type: ButtonType.button,
                            events: {'mousedown': (event) => event.preventDefault()},
                            onClick: () => _openPackage(suggestions[i], compare: true),
                            [.text('Compare')],
                          ),
                      ],
                    ),
                ],
              ),
          ],
        ),
        div(
          classes: 'spans',
          [
            for (final span in TimeSpan.values)
              button(
                classes: controller.timeSpan == span ? 'span active' : 'span',
                type: ButtonType.button,
                onClick: () => unawaited(controller.setTimeSpan(span)),
                [.text(span.label)],
              ),
          ],
        ),
      ],
    );
  }

  List<String> _currentPackages(BuildContext context) {
    final raw = RouteState.of(context).params['packages'];
    if (raw == null || raw.isEmpty) return const [];
    return raw.split(',').where((item) => item.isNotEmpty).toList();
  }

  void _openPackage(String package, {bool compare = false}) {
    final name = package.trim();
    if (name.isEmpty) return;
    final controller = AppScope.of(context);
    final current = _currentPackages(context);
    if (!compare && current.length == 1 && current.first == name) {
      setState(() => _open = false);
      return;
    }
    if (compare && current.contains(name)) {
      controller.snack('Already comparing $name');
      return;
    }
    final next = compare ? [...current, name] : [name];
    if (next.length > chartColors.length) {
      controller.snack('Cannot add more packages to compare');
      return;
    }
    setState(() {
      _query = '';
      _open = false;
    });
    context.push('/packages/${next.join(',')}');
  }
}

class FooterBar extends StatelessComponent {
  const FooterBar({super.key});

  @override
  Component build(BuildContext context) {
    return footer(
      classes: 'footer',
      [
        div(
          classes: 'footer-bar',
          [
            div(
              classes: 'footer-links',
              [
                const GitHubButton(repo: 'Rexios80/pub_stats'),
                a(
                  href: 'https://discord.gg/v5yAdrucdG',
                  classes: 'icon-btn social',
                  target: Target.blank,
                  attributes: {'aria-label': 'Discord', 'rel': 'noopener noreferrer'},
                  [const DiscordIcon()],
                ),
                button(
                  classes: 'footer-link',
                  type: ButtonType.button,
                  onClick: AppScope.of(context).showLicenses,
                  [.text('Licenses')],
                ),
              ],
            ),
            a(
              href: 'https://jaspr.site',
              classes: 'jaspr-badge',
              target: Target.blank,
              attributes: {'rel': 'noopener noreferrer'},
              [
                switch (AppScope.of(context).theme) {
                  ThemePreference.dark => const JasprBadge.darkTwoTone(),
                  ThemePreference.light => const JasprBadge.lightTwoTone(),
                  ThemePreference.system =>
                    web.window.matchMedia('(prefers-color-scheme: dark)').matches
                        ? const JasprBadge.darkTwoTone()
                        : const JasprBadge.lightTwoTone(),
                },
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class SnackBar extends StatelessComponent {
  const SnackBar({required this.message, super.key});

  final SnackMessage message;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'snack',
      attributes: {'role': 'status'},
      [
        span([.text(message.text)]),
        if (message.actionLabel case final label?)
          button(
            type: ButtonType.button,
            onClick: message.action,
            [.text(label)],
          ),
      ],
    );
  }
}

class DialogLayer extends StatelessComponent {
  const DialogLayer({super.key});

  @override
  Component build(BuildContext context) {
    final controller = AppScope.of(context);
    return div(
      classes: 'scrim',
      events: {'click': (_) => controller.closeDialog()},
      [
        div(
          classes: 'dialog',
          attributes: {'role': 'dialog'},
          events: {'click': (event) => event.stopPropagation()},
          [
            if (controller.popularityInfo) ...[
              h2([.text('About Popularity Score')]),
              p([
                .text('Popularity score is a metric that attempts to quantify the overall popularity of a package.'),
              ]),
              p([
                .text(
                  'Modern popularity scores are calculated by pub_stats based on the raw download count of a package relative to others.',
                ),
              ]),
              p([
                .text(
                  'Legacy popularity scores were calculated by pub.dev based on a filtered download count, but are no longer computed.',
                ),
              ]),
            ],
            if (controller.licensesOpen) ...[
              h2([.text('Licenses')]),
              p([.text('pubstats is open source. The libraries used to build this site include:')]),
              ul([
                li([
                  a(
                    href: 'https://github.com/schultek/jaspr',
                    target: Target.blank,
                    [
                      span([.text('Jaspr')]),
                      .text(' (MIT)'),
                    ],
                  ),
                ]),
                li([.text('Firebase JavaScript SDK (Apache-2.0)')]),
                li([.text('Roboto and Material Symbols (Apache-2.0)')]),
                li([.text('Lucide (ISC)')]),
              ]),
            ],
            if (controller.packageDialog case final packages?) ...[
              h2([.text(controller.packageDialogTitle ?? 'Packages')]),
              div(
                classes: 'package-list',
                [
                  if (packages.isEmpty)
                    p([.text('No packages')])
                  else
                    for (final package in packages)
                      button(
                        type: ButtonType.button,
                        onClick: () {
                          controller.closeDialog();
                          context.push('/packages/$package');
                        },
                        [.text(package)],
                      ),
                ],
              ),
            ],
            div(
              classes: 'actions',
              [
                button(
                  classes: 'text-btn',
                  type: ButtonType.button,
                  onClick: controller.closeDialog,
                  [.text('Close')],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
