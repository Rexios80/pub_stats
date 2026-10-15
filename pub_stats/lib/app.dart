import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'app_controller.dart';
import 'components/shell.dart';
import 'pages/alerts.dart';
import 'pages/home.dart';

class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _controller = AppController();

  @override
  void initState() {
    super.initState();
    unawaited(_controller.start());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        ShellRoute(
          builder: (context, state, child) => Shell(controller: _controller, child: child),
          routes: [
            Route(path: '/', title: 'pubstats', builder: (context, state) => const Home()),
            Route(path: '/packages/:packages', title: 'pubstats', builder: (context, state) => const Home()),
            Route(path: '/alerts', title: 'Alerts · pubstats', builder: (context, state) => const AlertsPage()),
          ],
        ),
      ],
      errorBuilder: (context, state) => Shell(
        controller: _controller,
        child: div(
          classes: 'page message',
          [
            h1([.text('Page not found')]),
            const Link(to: '/', child: .text('Back to pubstats')),
          ],
        ),
      ),
    );
  }
}
