import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/view/widget/time_span_selector.dart';

class StickyHeader extends SliverPersistentHeaderDelegate {
  static const _searchBarSize = 104.0;

  final _dataController = GetIt.I<DataController>();
  final _searchController = SearchController();

  StickyHeader({Key? key});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // overlapsContent does not work if a header is pinned
    // https://github.com/flutter/flutter/issues/26667#issuecomment-937974056
    overlapsContent = shrinkOffset > 0;
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      elevation: overlapsContent ? 4 : 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 8),
              TimeSpanSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchAnchor.bar(
      barLeading: FastBuilder(() {
        if (_dataController.loading.value) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Icon(Icons.search);
        }
      }),
      searchController: _searchController,
      barHintText: 'Enter a package name',
      onSubmitted: _submit,
      suggestionsBuilder: (context, controller) {
        final text = controller.text;
        if (text.isEmpty) return [];
        return [
          for (final suggestion in {text, ..._dataController.complete(text)})
            ListTile(
              title: Text(suggestion),
              trailing: _dataController.loadedStats.isEmpty
                  ? null
                  : TextButton(
                      onPressed: () => _submit(suggestion, clear: false),
                      child: const Text('Compare'),
                    ),
              onTap: () => _submit(suggestion),
            ),
        ];
      },
      barTrailing: [
        IconButton(
          icon: const Icon(Icons.casino),
          onPressed: _dataController.feelingLucky,
          tooltip: 'Feeling lucky?',
        ),
      ],
    );
  }

  // Widget _buildSearchBar() {
  //   return Card(
  //     clipBehavior: Clip.antiAlias,
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: TypeAheadField<String>(
  //             controller: _searchController,
  //             builder: (context, controller, node) => TextField(
  //               controller: controller,
  //               focusNode: node,
  //               autofocus: true,
  //               autocorrect: false,
  //               textCapitalization: TextCapitalization.none,
  //               decoration: const InputDecoration(
  //                 border: InputBorder.none,
  //                 hintText: 'Enter a package name',
  //               ),
  //               inputFormatters: [
  //                 FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_\-]')),
  //               ],
  //               onSubmitted: _submit,
  //             ),
  //             suggestionsCallback: (pattern) {
  //               if (pattern.isEmpty) return [];
  //               return {
  //                 pattern,
  //                 ..._dataController.complete(pattern),
  //               }.toList();
  //             },
  // itemBuilder: (context, suggestion) => ListTile(
  //   title: Text(suggestion),
  //   trailing: _dataController.loadedStats.isEmpty
  //       ? null
  //       : TextButton(
  //           onPressed: () {
  //             _dataController.fetchStats(suggestion, clear: false);
  //             _searchController.clear();
  //           },
  //           child: const Text('Compare'),
  //         ),
  // ),
  //             emptyBuilder: (context) => const SizedBox.shrink(),
  //             errorBuilder: (context, error) {
  //               _logger.e(error);
  //               return const ListTile(title: Text('Error searching packages'));
  //             },
  //             debounceDuration: Duration.zero,
  //             onSelected: _submit,
  //           ),
  //         ),
  //         const SizedBox(width: 16),
  //         IconButton(
  //           icon: const Icon(Icons.casino),
  //           onPressed: _dataController.feelingLucky,
  //           tooltip: 'Feeling lucky?',
  //         ),
  //         const SizedBox(width: 8),
  //       ],
  //     ),
  //   );
  // }

  void _submit(String value, {bool clear = true}) {
    _dataController.fetchStats(value, clear: clear);
    _searchController.clear();
  }

  @override
  double get maxExtent => _searchBarSize;

  @override
  double get minExtent => _searchBarSize;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
