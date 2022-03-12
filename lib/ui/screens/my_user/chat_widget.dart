import 'package:app_2i2i/infrastructure/models/chat_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../infrastructure/commons/theme.dart';
import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom_profile_image_view.dart';

class ChatWidget extends ConsumerStatefulWidget {
  final UserModel user;

  const ChatWidget({Key? key, required this.user}) : super(key: key);

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends ConsumerState<ChatWidget> {
  TextEditingController commentController = TextEditingController();
  bool isLargeScreen = false;

  @override
  Widget build(BuildContext context) {
    final userModelChanger = ref.watch(userChangerProvider)!;
    final currentUserId = ref.watch(myUIDProvider)!;
    final currentUserAsyncValue = ref.watch(userProvider(currentUserId));
    final currentUser = currentUserAsyncValue.value!;
    isLargeScreen = (MediaQuery.of(context).size.width > 600);

    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery
          .of(context)
          .viewInsets
          .bottom),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          height: isLargeScreen ? 844 : MediaQuery
              .of(context)
              .size
              .width,
          width: isLargeScreen ? 500 : MediaQuery
              .of(context)
              .size
              .width,
          margin: EdgeInsets.only(
              top: kToolbarHeight + 12, right: 8, left: 8, bottom: 12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: kIsWeb,
                child: Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 15,
                    child: IconButton(
                      iconSize: 15,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close, color: Colors.black),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirestoreDatabase().getChat(widget.user.id),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      List<ChatModel> chatList = snapshot.data;
                      return ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          ChatModel chat = chatList[index];

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            // padding: EdgeInsets.all(8),
                            // color: Colors.amber,
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: ProfileWidget(
                                  stringPath: chat.writerName,
                                  imageType: ImageType.NAME_IMAGE,
                                  radius: 44,
                                  hideShadow: true,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      ?.copyWith(fontWeight: FontWeight.w800)),
                              title: Text(chat.writerName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .primaryColorLight)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(chat.message,
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .primaryColorLight)),
                              ),
                            ),
                          );
                        },
                        itemCount: chatList.length,
                        reverse: true,
                      );
                    }
                    return Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator());
                  },
                ),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.white,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: commentController,
                      style: TextStyle(color: AppTheme().cardDarkColor),
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        filled: true,
                        fillColor: Theme.of(context).primaryColorLight,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        // suffixIcon: Icon(Icons.mic),
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  InkResponse(
                    onTap: () async {
                      if (commentController.text.isNotEmpty) {
                        await userModelChanger.addComment(
                            widget.user.id,
                            ChatModel(
                                message: commentController.text,
                                ts: DateTime.now().toUtc(),
                                writerName: currentUser.name,
                                writerUid: currentUserId));
                        commentController.clear();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 23,
                        child: SvgPicture.asset('assets/icons/send.svg',
                            width: 20, height: 20),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
