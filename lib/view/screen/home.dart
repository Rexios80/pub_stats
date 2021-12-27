import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/view/widget/footer.dart';
import 'package:pub_stats/view/widget/header.dart';
import 'package:pub_stats/view/widget/search_bar.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:sliver_tools/sliver_tools.dart';

class Home extends StatelessWidget {
  final _controller = GetIt.I<DataController>();

  Home({Key? key}) : super(key: key);

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
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Footer(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
