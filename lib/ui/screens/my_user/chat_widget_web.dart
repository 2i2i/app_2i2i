import 'package:app_2i2i/infrastructure/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../infrastructure/commons/theme.dart';
import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom_profile_image_view.dart';

class ChatWidgetWeb extends ConsumerStatefulWidget {
  final UserModel user;

  const ChatWidgetWeb({Key? key, required this.user}) : super(key: key);

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends ConsumerState<ChatWidgetWeb> {
  TextEditingController commentController = TextEditingController();

  //bool isLargeScreen = false;

  @override
  Widget build(BuildContext context) {
    final userModelChanger = ref.watch(userChangerProvider)!;
    final currentUserId = ref.watch(myUIDProvider)!;
    final currentUserAsyncValue = ref.watch(userProvider(currentUserId));
    final currentUser = currentUserAsyncValue.value!;

    return Container(
      margin: EdgeInsets.only(
          top:MediaQuery.of(context).size.height/22,
          right: MediaQuery.of(context).size.width/33,
          left: MediaQuery.of(context).size.width/1.834,
          bottom: MediaQuery.of(context).size.height/24,
      ),
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
                icon: Icon(Icons.close, color: Theme.of(context).shadowColor),
              ),
            ),
          ),
          SizedBox(
            height: kToolbarHeight,
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
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: ProfileWidget(
                              stringPath: chat.writerName,
                              imageType: ImageType.NAME_IMAGE,
                              radius: 44,
                              hideShadow: true,
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w800)),
                          title: Row(
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
            color: Theme.of(context).cardColor,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                  controller: commentController,
                  style: TextStyle(color: AppTheme().cardDarkColor),
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
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
                  if (commentController.text.isNotEmpty) {
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
