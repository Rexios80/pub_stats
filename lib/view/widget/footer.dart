import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/constant/links.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/view/widget/padded_vertical_divider.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  final _controller = GetIt.I<DataController>();

  Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FooterStat(
            stat: _controller.packageCount,
            label: 'Packages Scanned',
          ),
          const PaddedVerticalDivider(),
          FooterStat(
            stat: _controller.lastUpdatedDate,
            label: 'Last Updated',
          ),
          const PaddedVerticalDivider(),
          const FooterLink(
            url: Links.github,
            tooltip: 'GitHub',
            icon: FontAwesomeIcons.github,
          ),
          const PaddedVerticalDivider(),
          const FooterLink(
            url: Links.discord,
            tooltip: 'Discord',
            icon: FontAwesomeIcons.discord,
          ),
        ],
      ),
    );
  }
}

class FooterStat extends StatelessWidget {
  final String stat;
  final String label;

  const FooterStat({
    Key? key,
    required this.stat,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(stat),
        const SizedBox(height: 4),
        Text(label, style: context.textTheme.caption),
      ],
    );
  }
}

class FooterLink extends StatelessWidget {
  final String url;
  final String tooltip;
  final IconData icon;

  const FooterLink({
    Key? key,
    required this.url,
    required this.tooltip,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () => launch(url),
      tooltip: tooltip,
      icon: FaIcon(icon),
    );
  }
}
