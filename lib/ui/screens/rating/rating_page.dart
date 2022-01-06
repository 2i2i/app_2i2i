import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/models/meeting_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';
import 'widgets/rating_tile.dart';

class RatingPage extends ConsumerStatefulWidget {

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends ConsumerState<RatingPage> {
  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider)!;
    final userModel = ref.watch(userPageViewModelProvider(uid));

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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: double.infinity,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${(userModel?.user.numRatings ?? 0) * 5}Ratings',
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .tabBarTheme
                            .unselectedLabelColor)),
                SizedBox(width: 4),
                Text(
                    '(${(/*widget.userModel?.numRatings*/ ratingList.length)} reviews)',
                    style: Theme.of(context).textTheme.caption),
              ],
            ),
            Expanded(
              flex: 5,
              child: ListView.builder(
                  itemCount: /*ratingList.length*/ 10,
                  itemBuilder: (BuildContext context, int index) {
                    // RatingModel ratingModel = ratingList[index];
                    RatingModel ratingModel = RatingModel(
                        rating: 4,
                        comment:
                            "“It was great to talk to you, definely will talk later”");
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
