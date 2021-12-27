import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/constant/links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fast_ui/fast_ui.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FooterIconLink(
              url: Links.github,
              tooltip: 'GitHub',
              icon: FontAwesomeIcons.github,
            ),
            SizedBox(width: 16),
            FooterIconLink(
              url: Links.discord,
              tooltip: 'Discord',
              icon: FontAwesomeIcons.discord,
            ),
          ],
        ),
        InkWell(
          borderRadius: AppTheme.pillRadius,
          onTap: () => launch(Links.fastUi),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Made with fast_ui',
              style: context.textTheme.caption,
            ),
          ),
        ),
      ],
    );
  }
}

class FooterIconLink extends StatelessWidget {
  final String url;
  final String tooltip;
  final IconData icon;

  const FooterIconLink({
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
