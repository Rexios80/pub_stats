import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/auth_controller.dart';
import 'package:pub_stats/view/widget/footer.dart';
import 'package:pub_stats/view/widget/header.dart';
import 'package:pub_stats/view/widget/sticky_header.dart';
import 'package:pub_stats/view/widget/stats/stats_view.dart';

class Home extends StatelessWidget {
  static final _auth = GetIt.I<AuthController>();

  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              title: FittedBox(fit: BoxFit.scaleDown, child: Header()),
            ),
            actions: [
              FastBuilder(() {
                if (_auth.user.value != null) {
                  return PopupMenuButton(
                    child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(_auth.user.value!.photoURL ?? ''),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: _auth.signOut,
                        child: const Text('Sign out'),
                      ),
                    ],
                  );
                } else {
                  return ElevatedButton(
                    onPressed: _auth.signInWithGoogle,
                    child: const Text('Sign in'),
                  );
                }
              }),
              const SizedBox(width: 8),
            ],
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
