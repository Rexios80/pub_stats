import 'package:flutter/material.dart';
import 'package:pub_stats/view/widget/footer.dart';
import 'package:pub_stats/view/widget/header.dart';
import 'package:pub_stats/view/widget/search_bar.dart';
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
              const Header(),
              const SizedBox(height: 20),
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
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Footer(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
