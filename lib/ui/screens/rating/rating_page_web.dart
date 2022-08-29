import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/models/meeting_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../app/wait_page.dart';
import 'widgets/rating_tile.dart';

class RatingPageWeb extends ConsumerStatefulWidget {
  final String uid;

  RatingPageWeb({required this.uid});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends ConsumerState<RatingPageWeb> {
  UserModel? user;

  @override
  Widget build(BuildContext context) {
    user = ref.watch(userPageViewModelProvider(widget.uid))?.user;

    final ratingListAsyncValue = ref.watch(ratingListProvider(widget.uid));

    if (haveToWait(ratingListAsyncValue)) {
      return WaitPage();
    } else if (ratingListAsyncValue is AsyncError) {
      return Scaffold(
        body: Center(
          child: Text(Keys.somethingWantWrong.tr(context), style: Theme.of(context).textTheme.subtitle1),
        ),
      );
    }

    final ratingList = ratingListAsyncValue.asData!.value;
    final totalRating = (user!.rating * 5).toStringAsFixed(1);

    return Scaffold(
      appBar: CustomAppbarHolder(),
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width/35,
            //vertical: MediaQuery.of(context).size.width/35,
        ),
       // width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: kRadialReactionRadius,),
                Text(
                  Keys.ratings.tr(context),
                  style: Theme.of(context).textTheme.headline6,
                ),
                Spacer(),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColorLight, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '($totalRating/5)',
                          style: Theme.of(context).textTheme.subtitle2,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 16,
                            child: Icon(
                              Icons.star
                            ),
                          ),
                          Text(
                            Keys.noRatingsFound.tr(context),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: ratingList.length,
                      itemBuilder: (BuildContext context, int index) {
                        RatingModel ratingModel = ratingList[index];
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
