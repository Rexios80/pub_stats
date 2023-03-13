import 'package:flutter/material.dart';
import 'package:pub_stats/view/widget/footer.dart';
import 'package:pub_stats/view/widget/header.dart';
import 'package:pub_stats/view/widget/sticky_header.dart';
import 'package:pub_stats/view/widget/stats/stats_view.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 100, bottom: 40),
            sliver: SliverToBoxAdapter(child: FittedBox(child: Header())),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyHeader(),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            sliver: StatsView(),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Footer(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
