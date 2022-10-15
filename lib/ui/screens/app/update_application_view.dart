import 'package:flutter/material.dart';

import '../../../infrastructure/models/app_version_model.dart';

class UpdateApplicationView extends StatelessWidget {
  final AppVersionModel appVersionModel;

  UpdateApplicationView({Key? key, required this.appVersionModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text("Update App?", style: Theme.of(context).textTheme.titleLarge),
          Text("A new version of Upgrader is available! Version 1.58.0 is now available-you have . Would you like to update to now?",
              style: Theme.of(context).textTheme.titleLarge),
          Text("Release Notes:", style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
