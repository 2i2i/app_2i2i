import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/models/meeting_model.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';
import 'widgets/rating_tile.dart';

class RatingPage extends ConsumerStatefulWidget {
  final UserModel? userModel;

  RatingPage({this.userModel});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends ConsumerState<RatingPage> {
  UserModel? userModel;

  @override
  Widget build(BuildContext context) {
    String uid;
    if (widget.userModel != null) {
      uid = widget.userModel!.id;
      userModel = widget.userModel;
    } else {
      uid = ref.watch(myUIDProvider)!;
      userModel = ref.watch(userPageViewModelProvider(uid))?.user;
    }

    final ratingListAsyncValue = ref.watch(ratingListProvider(uid));

    if (ratingListAsyncValue is AsyncLoading || userModel is AsyncLoading) {
      return WaitPage();
    } else if (ratingListAsyncValue is AsyncError) {
      return Scaffold(
        body: Center(
          child: Text("Something want wrong"),
        ),
      );
    }

    final ratingList = ratingListAsyncValue.asData!.value;

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ratings',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Spacer(),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('(${(userModel?.rating ?? 0)}/5)',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(
                          Icons.star_purple500_outlined,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 5,
              child: ratingList.isEmpty
                  ? Center(
                      child: Text(
                      'No rating found',
                      style: Theme.of(context).textTheme.subtitle2,
                    ))
                  : ListView.builder(
                      itemCount: ratingList.length,
                      itemBuilder: (BuildContext context, int index) {
                        RatingModel ratingModel = ratingList[index];
                        // RatingModel ratingModel = RatingModel(rating: 4, comment: "“It was great to talk to you, definely will talk later”");
                        return RatingTile(
                          ratingModel: ratingModel,
                        );
                      }),
            ),
          ],
        ),
      ),
    );
  }
}
