import 'package:flutter/material.dart';

class ChipTile extends StatelessWidget {
  const ChipTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        "label",
        style: Theme.of(context).textTheme.caption?.copyWith(
          color: Theme.of(context).cardColor
        ),
      ),
      backgroundColor: Theme.of(context).iconTheme.color,
      padding: EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
