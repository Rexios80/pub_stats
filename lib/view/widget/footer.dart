import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/constant/app_image.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/constant/links.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/repo/url_repo.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Footer extends StatelessWidget {
  final _dataController = GetIt.I<DataController>();
  final _url = GetIt.I<UrlRepo>();

  Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FooterIconLink(
              url: Links.github,
              icon: FontAwesomeIcons.github,
            ),
            SizedBox(width: 16),
            FooterIconLink(
              url: Links.discord,
              icon: FontAwesomeIcons.discord,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FooterTextLink(
              label: 'Built with fast_ui',
              onTap: () => launchUrlString(Links.fastUi),
            ),
            FastBuilder(
              () => FooterTextLink(
                label: 'My package stats',
                onTap: _dataController.loadingDeveloperPackageStats.value
                    ? null
                    : () {
                        if (_url.isDeveloperPackages()) return;
                        _dataController.fetchDeveloperPackageStats();
                      },
              ),
            ),
            FooterTextLink(
              label: 'Licenses',
              onTap: () => FastOverlays.showLicensePage(
                applicationIcon: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SvgPicture.asset(AppImage.logo, height: 75),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FooterIconLink extends StatelessWidget {
  final String url;
  final IconData icon;

  const FooterIconLink({
    super.key,
    required this.url,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () => launchUrlString(url),
      icon: FaIcon(icon),
    );
  }
}

class FooterTextLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const FooterTextLink({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.pillRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(
          label,
          style: context.textTheme.bodySmall,
        ),
      ),
    );
  }
}
