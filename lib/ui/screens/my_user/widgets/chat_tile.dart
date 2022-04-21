import 'package:app_2i2i/infrastructure/models/chat_model.dart';
import 'package:flutter/material.dart';

import '../../../commons/custom_profile_image_view.dart';

class ChatTile extends StatelessWidget {
  final ChatMessageModel chatMessageModel;

  const ChatTile({Key? key, required this.chatMessageModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: ProfileWidget(
            stringPath: chatMessageModel.chatMessageUserName ?? '',
            imageType: ImageType.NAME_IMAGE,
            radius: 44,
            hideShadow: true,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                ?.copyWith(fontWeight: FontWeight.w800)),
        title: Text(chatMessageModel.chatMessageUserName ?? '',
            style: Theme.of(context)
                .textTheme
                .caption
                ?.copyWith(color: Theme.of(context).primaryColorLight)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(chatMessageModel.chatMessage ?? '',
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  ?.copyWith(color: Theme.of(context).primaryColorLight)),
        ),
      ),
    );
  }
}
