import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';

class SearchBar extends SliverPersistentHeaderDelegate {
  static const _searchBarSize = 56.0;

  final _dataController = GetIt.I<DataController>();

  SearchBar({Key? key});

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
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchBar(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: FastBuilder(() {
            if (_dataController.loading.value) {
              return const Center(
                child: SizedBox(
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return const Icon(Icons.search);
            }
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TypeAheadField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              autofocus: true,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter a package name',
              ),
              inputFormatters: [
                // Don't allow spaces
                FilteringTextInputFormatter.deny(' '),
              ],
              onSubmitted: _dataController.fetchStats,
            ),
            suggestionsCallback: (pattern) {
              if (pattern.isEmpty) {
                return [];
              }
              return _dataController.searchPackages(pattern);
            },
            itemBuilder: (context, suggestion) =>
                ListTile(title: Text(suggestion)),
            noItemsFoundBuilder: (context) =>
                const ListTile(title: Text('No packages found')),
            errorBuilder: (context, error) =>
                const ListTile(title: Text('Error searching packages')),
            debounceDuration: Duration.zero,
            onSuggestionSelected: _dataController.fetchStats,
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => _searchBarSize;

  @override
  double get minExtent => _searchBarSize;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
