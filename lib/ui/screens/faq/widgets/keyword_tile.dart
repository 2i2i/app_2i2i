import 'package:flutter/material.dart';

class ChipTile extends StatelessWidget {
  final String value;

  const ChipTile({required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        value,
        style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).cardColor),
      ),
      backgroundColor: Theme.of(context).iconTheme.color,
      padding: EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
