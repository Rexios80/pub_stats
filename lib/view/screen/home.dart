import 'package:flutter/material.dart';
import 'package:pub_stats/view/widget/footer.dart';
import 'package:pub_stats/view/widget/header.dart';
import 'package:pub_stats/view/widget/search_bar.dart';
import 'package:pub_stats/view/widget/stats_view.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:fast_ui/fast_ui.dart';

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
              const Header(),
              const SizedBox(height: 20),
              SliverAppBar(
                pinned: true,
                backgroundColor: context.theme.scaffoldBackgroundColor,
                title: Center(
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
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StatsView(),
                    ),
                    const Spacer(),
                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Footer(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
