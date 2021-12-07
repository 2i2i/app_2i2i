import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:go_router/go_router.dart';

class NotificationWidget {
  static showBidNotification(BuildContext context) {
    showToastWidget(
      Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme().pink,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          onTap: () => context.goNamed('my_user'),
          leading: Image.asset('assets/logo.png', height: 80, width: 80),
          title: HeadLineSixText(
              title: "You got new bid now!", textColor: AppTheme().brightBlue),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => context.goNamed('my_user'),
                  child: ButtonText(
                    title: "View Bid",
                    textColor: AppTheme().black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      context: context,
      position: StyledToastPosition.top,
      animDuration: Duration(seconds: 1),
      duration: Duration(seconds: 4),
      animationBuilder: (BuildContext context, AnimationController controller,
          Duration duration, Widget child) {
        return SlideTransition(
            position: getAnimation<Offset>(
                Offset(0.0, -4.0), Offset(0, 0), controller,
                curve: Curves.easeInOutExpo),
            child: child);
      },
      reverseAnimBuilder: (BuildContext context, AnimationController controller,
          Duration duration, Widget child) {
        return SlideTransition(
          position: getAnimation<Offset>(
              Offset(0.0, 0.0), Offset(0.0, -4.0), controller,
              curve: Curves.easeInOutExpo),
          child: child,
        );
      },
    );
  }


}
