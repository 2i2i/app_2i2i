import 'package:flutter/material.dart';

import '../../../../infrastructure/commons/theme.dart';
import '../../../commons/custom_profile_image_view.dart';

class LongestSpeedPage extends StatefulWidget {
  const LongestSpeedPage({Key? key}) : super(key: key);

  @override
  _LongestSpeedPageState createState() => _LongestSpeedPageState();
}

class _LongestSpeedPageState extends State<LongestSpeedPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (BuildContext context, int index) => ListTile(
        title: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme().tabColor,
              child: Text(
                '$index',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontWeight: FontWeight.w800,color: Theme.of(context).disabledColor),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  TextProfileView(
                      text: "name",
                      statusColor: Colors.green,
                      hideShadow: true,
                      radius: kToolbarHeight + 6,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme().tabTextColor)),
                  SizedBox(width: 8),
                  Text('Guy Hawkins'.toUpperCase(),
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme().tabTextColor)),
                ],
              ),
            ),
            Text('${index * 100}'.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }
}
