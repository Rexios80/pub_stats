import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

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
  DiscordTarget? _target;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateComponent(covariant DiscordWebhookDetails oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.id == component.id && oldComponent.token == component.token) return;
    _target = null;
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
    _timer = Timer(const Duration(milliseconds: 250), () => unawaited(_load(ticket)));
  }

  Future<void> _load(int ticket) async {
    final target = await lookupDiscordWebhook(component.id, component.token);
    if (!mounted || ticket != _ticket) return;
    setState(() {
      _target = target;
      _done = true;
    });
  }

  @override
  Component build(BuildContext context) {
    if (!_done) return span(classes: 'alert-meta', [.text('Looking up webhook')]);
    final server = _target?.server;
    final channel = _target?.channel;
    if (server == null && channel == null) {
      return span(classes: 'alert-meta', [.text('Server and channel names unavailable')]);
    }
    final label = [
      ?server,
      if (channel != null) '#$channel',
    ].join(' · ');
    return span(classes: 'alert-meta', [.text(label)]);
  }
}
