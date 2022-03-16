import 'package:flutter/material.dart';

import 'widgets/chip_tile.dart';

class KeywordsList extends StatefulWidget {
  const KeywordsList({Key? key}) : super(key: key);

  @override
  State<KeywordsList> createState() => _KeywordsListState();
}

class _KeywordsListState extends State<KeywordsList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(10, (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ChipTile(),
        )),
      ),
    );
  }
}
