import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../infrastructure/models/user_model.dart';
import 'chat_widget.dart';
import 'chat_widget_web.dart';

class ChatWidgetHolder extends ConsumerStatefulWidget {
  final UserModel user;

  const ChatWidgetHolder({Key? key, required this.user}) : super(key: key);

  @override
  _ChatWidgetHolderState createState() => _ChatWidgetHolderState();
}

class _ChatWidgetHolderState extends ConsumerState<ChatWidgetHolder> {
  TextEditingController commentController = TextEditingController();
  bool isLargeScreen = false;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => ChatWidget(
        user: widget.user,
      ),
      tablet: (BuildContext context) => ChatWidget(user: widget.user),
      desktop: (BuildContext context) => ChatWidgetWeb(
        user: widget.user,
      ),
    );
  }
}
