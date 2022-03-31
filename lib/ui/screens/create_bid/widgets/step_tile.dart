import 'package:flutter/material.dart';

class StepTile extends StatelessWidget {
  const StepTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          width: 30,
          margin: EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text('1',style: Theme.of(context).textTheme.labelSmall)),
        ),
        Text('Details')
      ],
    );
  }
}
