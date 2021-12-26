import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchBar extends StatelessWidget {
  final _textController = TextEditingController();

  SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
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
                onSubmitted: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
