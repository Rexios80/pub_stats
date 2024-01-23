import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/user_controller.dart';
import 'package:pub_stats/view/screen/alerts_manager.dart';
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
          SliverAppBar.large(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.zero,
              title: FittedBox(fit: BoxFit.scaleDown, child: Header()),
            ),
            actions: const [
              AppBarActions(),
              SizedBox(width: 8),
            ],
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyHeader(),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(top: 40, left: 16, right: 16),
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

class AppBarActions extends StatelessWidget {
  static final _user = GetIt.I<UserController>();

  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return FastBuilder(() {
      if (_user.user.value != null) {
        return Row(
          children: [
            ElevatedButton(
              onPressed: () => context.push(AlertsManager()),
              child: const Text('Manage Alerts'),
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              child: CircleAvatar(
                foregroundImage: NetworkImage(_user.user.value!.photoURL ?? ''),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: _user.signOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ],
        );
      } else {
        return ElevatedButton(
          onPressed: _user.signInWithGoogle,
          child: const Text('Sign in'),
        );
      }
    });
  }
}
