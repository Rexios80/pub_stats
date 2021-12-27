import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/controller/data_controller.dart';

class SearchBar extends StatelessWidget {
  final _dataController = GetIt.I<DataController>();
  final _textController = TextEditingController();

  SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.pillRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
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
                  return IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _submit,
                  );
                }
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter a package name',
                ),
                inputFormatters: [
                  // Don't allow spaces
                  FilteringTextInputFormatter.deny(' '),
                ],
                onSubmitted: (value) => _submit(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_textController.text.isNotEmpty) {
      _dataController.fetchStats(_textController.text);
    }
  }
}
