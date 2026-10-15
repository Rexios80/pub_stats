import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../app_scope.dart';
import '../format.dart';
import '../models.dart';

class Icon extends StatelessComponent {
  const Icon(this.name, {super.key});

  final String name;

  @override
  Component build(BuildContext context) {
    return span(
      classes: 'icon',
      attributes: {'aria-hidden': 'true'},
      [.text(name)],
    );
  }
}

class Spinner extends StatelessComponent {
  const Spinner({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'spinner',
      attributes: {'role': 'status', 'aria-label': 'Loading'},
      [],
    );
  }
}

class LoadingView extends StatelessComponent {
  const LoadingView({this.label = 'Loading pubstats', super.key});

  final String label;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'loading',
      [
        const Spinner(),
        p([.text(label)]),
      ],
    );
  }
}

class ShieldsBadge extends StatelessComponent {
  const ShieldsBadge({required this.package, required this.kind, required this.value, super.key});

  final String package;
  final BadgeKind kind;
  final Object? value;

  @override
  Component build(BuildContext context) {
    final hint = titleCase(kind.name);
    final url = 'https://pubstats.dev/badges/packages/$package/${kind.name}.svg';
    final markdown = '[![PubStats $hint]($url)](https://pubstats.dev/packages/$package)';
    return button(
      classes: 'badge',
      type: ButtonType.button,
      attributes: {'title': 'Copy $hint badge markdown'},
      onClick: () {
        final controller = AppScope.of(context);
        unawaited(
          controller.copy(markdown).then((_) {
            controller.snack('Badge markdown copied to clipboard');
          }),
        );
      },
      [
        span(
          classes: 'badge-label',
          [
            img(src: 'images/badge-logo.svg', alt: '', width: 14, height: 14),
            .text(kind.name),
          ],
        ),
        span(
          classes: 'badge-value',
          [.text(value?.toString() ?? 'N/A')],
        ),
      ],
    );
  }
}

class MenuButton extends StatefulComponent {
  const MenuButton({required this.icon, required this.label, required this.items, this.child, super.key});

  final String icon;
  final String label;
  final List<(String, void Function())> items;
  final Component? child;

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  var _open = false;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'popover',
      [
        button(
          classes: component.child == null ? 'icon-btn' : 'avatar',
          type: ButtonType.button,
          attributes: {'aria-label': component.label, 'aria-expanded': '$_open'},
          onClick: () => setState(() => _open = !_open),
          [component.child ?? Icon(component.icon)],
        ),
        if (_open) ...[
          div(
            classes: 'menu-scrim',
            events: {'click': (_) => setState(() => _open = false)},
            [],
          ),
          div(
            classes: 'menu',
            [
              for (final item in component.items)
                button(
                  type: ButtonType.button,
                  onClick: () {
                    setState(() => _open = false);
                    item.$2();
                  },
                  [.text(item.$1)],
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class GithubIcon extends StatelessComponent {
  const GithubIcon({super.key});

  @override
  Component build(BuildContext context) {
    return svg(
      viewBox: '0 0 24 24',
      attributes: {'aria-hidden': 'true'},
      [
        path(
          fill: .currentColor,
          d: 'M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12',
          [],
        ),
      ],
    );
  }
}

class DiscordIcon extends StatelessComponent {
  const DiscordIcon({super.key});

  @override
  Component build(BuildContext context) {
    return svg(
      viewBox: '0 0 24 24',
      attributes: {'aria-hidden': 'true'},
      [
        path(
          fill: .currentColor,
          d: 'M19.27 5.33C17.94 4.71 16.5 4.26 15 4a.1.1 0 0 0-.07.03c-.18.33-.39.76-.53 1.09a16.1 16.1 0 0 0-4.8 0c-.14-.34-.35-.76-.54-1.09-.01-.02-.04-.03-.07-.03-1.5.26-2.93.71-4.27 1.33-.01 0-.02.01-.03.02-2.72 4.07-3.47 8.03-3.1 11.95 0 .02.01.04.03.05 1.8 1.32 3.53 2.12 5.24 2.65.03.01.06 0 .07-.02.4-.55.76-1.13 1.07-1.74.02-.04 0-.08-.04-.09-.57-.22-1.11-.48-1.64-.78-.04-.02-.04-.08-.01-.11.11-.08.22-.17.33-.25.02-.02.05-.02.07-.01 3.44 1.57 7.15 1.57 10.55 0 .02-.01.05-.01.07.01.11.09.22.17.33.26.04.03.04.09-.01.11-.52.31-1.07.56-1.64.78-.04.01-.05.06-.04.09.32.61.68 1.19 1.07 1.74.03.01.06.02.09.01 1.72-.53 3.45-1.33 5.25-2.65.02-.01.03-.03.03-.05.44-4.53-.73-8.46-3.1-11.95-.01-.01-.02-.02-.04-.02zM8.52 14.91c-1.03 0-1.89-.95-1.89-2.12s.84-2.12 1.89-2.12c1.06 0 1.9.96 1.89 2.12 0 1.17-.84 2.12-1.89 2.12zm6.97 0c-1.03 0-1.89-.95-1.89-2.12s.84-2.12 1.89-2.12c1.06 0 1.9.96 1.89 2.12 0 1.17-.83 2.12-1.89 2.12z',
          [],
        ),
      ],
    );
  }
}
