import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/view/widget/time_span_selector.dart';

class StickyHeader extends SliverPersistentHeaderDelegate {
  static const _searchBarSize = 104.0;

  final _dataController = GetIt.I<DataController>();
  final _logger = GetIt.I<Logger>();

  final _textController = TextEditingController();

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
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSearchBar(),
                ),
              ),
              const SizedBox(height: 8),
              TimeSpanSelector(),
            ],
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
              controller: _textController,
              autofocus: true,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter a package name',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_\-]')),
              ],
              onSubmitted: _submit,
            ),
            suggestionsCallback: (pattern) {
              if (pattern.isEmpty) return [];
              return {
                pattern,
                ..._dataController.complete(pattern),
              };
            },
            itemBuilder: (context, suggestion) => ListTile(
              title: Text(suggestion),
              trailing: _dataController.loadedStats.isEmpty
                  ? null
                  : TextButton(
                      onPressed: () {
                        _dataController.fetchStats(suggestion, clear: false);
                        _textController.clear();
                      },
                      child: const Text('Compare'),
                    ),
            ),
            noItemsFoundBuilder: (context) =>
                const ListTile(title: Text('No packages found')),
            errorBuilder: (context, error) {
              _logger.e(error);
              return const ListTile(title: Text('Error searching packages'));
            },
            debounceDuration: Duration.zero,
            onSuggestionSelected: _submit,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.casino),
          onPressed: _dataController.feelingLucky,
          tooltip: 'Feeling lucky?',
        ),
      ],
    );
  }

  void _submit(String value) {
    _dataController.fetchStats(value);
    _textController.clear();
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
