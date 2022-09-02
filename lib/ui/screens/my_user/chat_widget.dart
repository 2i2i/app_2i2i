import 'package:app_2i2i/infrastructure/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/commons/keys.dart';
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

    return Container(
      height: MediaQuery.of(context).size.height,
      width: isLargeScreen ? 500 : MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: kToolbarHeight + 2, right: 8, left: 8, bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: CircleAvatar(
              radius: 18,
              child: IconButton(
                iconSize: 18,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close, color: Colors.black),
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirestoreDatabase().getChat(widget.user.id),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  List<ChatModel> chatList = snapshot.data;
                  return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      ChatModel chat = chatList[index];

                      return Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        //padding: EdgeInsets.only(top: 12),
                        // color: Colors.amber,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: StreamBuilder<UserModel>(
                              stream: FirestoreDatabase().userStream(uid: chat.writerUid),
                              builder: (context, snapshot) {
                                if (snapshot.data is UserModel) {
                                  UserModel user = snapshot.data!;
                                  return ProfileWidget(
                                      stringPath: (user.imageUrl ?? "").isEmpty ? user.name : user.imageUrl!,
                                      imageType: (user.imageUrl ?? "").isEmpty ? ImageType.NAME_IMAGE : ImageType.NETWORK_IMAGE,
                                      radius: 44,
                                      borderRadius: 10,
                                      hideShadow: true,
                                      showBorder: false,
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w800));
                                  /*  return ProfileWidget(
                                stringPath: chat.writerName,
                                imageType: ImageType.NAME_IMAGE,
                                radius: 44,
                                hideShadow: true,
                                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w800));*/
                                }
                                return ProfileWidget(
                                    stringPath: chat.writerName,
                                    imageType: ImageType.NAME_IMAGE,
                                    radius: 44,
                                    hideShadow: true,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w800));
                              }),
                          title: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(chat.writerName, style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).primaryColorLight)),
                                  Visibility(
                                    visible: chat.writerUid == widget.user.id,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(6)),
                                      child: Text('Host', style: Theme.of(context).textTheme.caption),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(DateFormat().add_yMMMMd().format(chat.ts.toLocal()),
                                      style: Theme.of(context).textTheme.overline?.copyWith(color: Theme.of(context).primaryColorLight)),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(chat.message,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                    fontWeight: chat.writerUid == widget.user.id ? FontWeight.bold : FontWeight.normal,
                                    color: Theme.of(context).primaryColorLight)),
                          ),
                        ),
                      );
                    },
                    itemCount: chatList.length,
                    reverse: true,
                  );
                }
                return Align(alignment: Alignment.bottomCenter, child: LinearProgressIndicator());
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
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                  controller: commentController,
                  style: TextStyle(color: AppTheme().cardDarkColor),
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: Keys.writeComment.tr(context),
                    filled: true,
                    fillColor: Theme.of(context).primaryColorLight,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    // suffixIcon: Icon(Icons.mic),
                  ),
                ),
              ),
              SizedBox(width: 4),
              InkResponse(
                onTap: () async {
                  if (commentController.text.toString().trim().isNotEmpty) {
                    await userModelChanger.addComment(widget.user.id,
                        ChatModel(message: commentController.text, ts: DateTime.now().toUtc(), writerName: currentUser.name, writerUid: currentUserId));
                    commentController.clear();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 23,
                    child: SvgPicture.asset('assets/icons/send.svg', width: 20, height: 20),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
