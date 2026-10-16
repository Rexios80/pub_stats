import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart' as web;

import '../discord_webhook.dart';

class DiscordWebhookDetails extends StatefulComponent {
  const DiscordWebhookDetails({required this.id, required this.token, super.key});

  final String id;
  final String token;

  @override
  State<DiscordWebhookDetails> createState() => _DiscordWebhookDetailsState();
}

class _DiscordWebhookDetailsState extends State<DiscordWebhookDetails> {
  Timer? _timer;
  var _ticket = 0;
  var _done = false;
  DiscordWebhook? _webhook;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateComponent(covariant DiscordWebhookDetails oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.id == component.id && oldComponent.token == component.token) return;
    _webhook = null;
    _done = false;
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _schedule() {
    _timer?.cancel();
    final ticket = ++_ticket;
    final cached = cachedDiscordWebhook(component.id, component.token);
    if (cached != null) {
      _webhook = cached.webhook;
      _done = true;
      return;
    }
    _timer = Timer(const Duration(milliseconds: 250), () => unawaited(_load(ticket)));
  }

  Future<void> _load(int ticket) async {
    final webhook = await lookupDiscordWebhook(component.id, component.token);
    if (!mounted || ticket != _ticket) return;
    setState(() {
      _webhook = webhook;
      _done = true;
    });
  }

  @override
  Component build(BuildContext context) {
    if (!_done) return span(classes: 'alert-meta', [.text('Looking up webhook')]);
    final webhook = _webhook;
    if (webhook == null) {
      final id = component.id;
      final label = id.isEmpty ? 'Discord webhook' : 'Discord webhook · $id';
      return div(
        classes: 'webhook',
        [
          span(classes: 'alert-meta', attributes: {'title': label}, [.text(label)]),
          span(classes: 'alert-meta', [.text('Channel details unavailable')]),
        ],
      );
    }

    final name = webhook.name ?? 'Discord webhook';
    final avatar = webhook.avatarUrl;
    return div(
      classes: 'webhook',
      [
        div(
          classes: 'webhook-name',
          [
            if (avatar != null)
              img(
                classes: 'webhook-avatar',
                src: avatar,
                alt: '',
                width: 20,
                height: 20,
                events: {
                  'error': (event) {
                    final target = event.target;
                    if (target == null) return;
                    (target as web.HTMLImageElement).style.display = 'none';
                  },
                },
              ),
            span(classes: 'alert-meta', attributes: {'title': name}, [.text(name)]),
            span(classes: 'pill', [.text(webhook.typeLabel)]),
          ],
        ),
        for (final line in webhook.lines) _line(line),
      ],
    );
  }

  Component _line(DiscordWebhookLine line) {
    final href = line.href;
    if (href == null) {
      return span(classes: 'alert-meta', attributes: {'title': line.text}, [.text(line.text)]);
    }
    return a(
      href: href,
      classes: 'alert-meta',
      target: Target.blank,
      attributes: {'rel': 'noopener noreferrer', 'title': line.text},
      [.text(line.text)],
    );
  }
}
