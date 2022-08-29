import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../infrastructure/models/user_model.dart';

class RatingPageHolder extends ConsumerStatefulWidget {
  final String uid;

  RatingPageHolder({required this.uid});
  @override
  _RatingPageHolderState createState() => _RatingPageHolderState();
}

class _RatingPageHolderState extends ConsumerState<RatingPageHolder> {
  UserModel? user;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => RatingPage(
        uid: widget.uid,
      ),
      tablet: (BuildContext context) => RatingPage(
        uid: widget.uid,
      ),
      desktop: (BuildContext context) => RatingPageWeb(
        uid: widget.uid,
      ),
    );
  }
}
