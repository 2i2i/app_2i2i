import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/models/meeting_model.dart';
import '../../../infrastructure/models/hangout_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';
import 'widgets/rating_tile.dart';

class RatingPage extends ConsumerStatefulWidget {
  final Hangout? hangout;

  RatingPage({this.hangout});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends ConsumerState<RatingPage> {
  Hangout? hangout;

  @override
  Widget build(BuildContext context) {
    String uid;
    if (widget.hangout != null) {
      uid = widget.hangout!.id;
      hangout = widget.hangout;
    } else {
      uid = ref.watch(myUIDProvider)!;
      hangout = ref.watch(userPageViewModelProvider(uid))?.hangout;
    }

    final ratingListAsyncValue = ref.watch(ratingListProvider(uid));

    if (haveToWait(ratingListAsyncValue)) {
      return WaitPage();
    } else if (ratingListAsyncValue is AsyncError) {
      return Scaffold(
        body: Center(
          child: Text("Something want wrong"),
        ),
      );
    }

    final ratingList = ratingListAsyncValue.asData!.value;
    final totalRating = (hangout!.rating * 5).toStringAsFixed(1);

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
                        Text('($totalRating/5)',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2,
                        ),
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
                      'No ratings found',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),)
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
