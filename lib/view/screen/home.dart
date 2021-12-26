import 'package:flutter/material.dart';
import 'package:pub_stats/view/widget/search_bar.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:sliver_tools/sliver_tools.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MultiSliver(
            children: [
              const SizedBox(height: 100),
              Text(
                'pubstats.dev',
                textAlign: TextAlign.center,
                style: context.textTheme.headline2!
                    .copyWith(color: context.textTheme.bodyText1!.color),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pub stats tracked over time',
                textAlign: TextAlign.center,
              ),
              SliverPinnedHeader(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SearchBar(),
                  ),
                ),
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('Footer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
