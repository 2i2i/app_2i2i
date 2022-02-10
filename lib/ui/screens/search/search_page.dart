import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/screens/hangout_setting/hangout_setting.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/hangout_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import 'widgtes/user_info_tile.dart';

class SearchPage extends ConsumerStatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initMethod();
  }

  void initMethod() {
    Future.delayed(Duration(seconds: 3)).then((value) {
      final uid = ref.watch(myUIDProvider)!;
      final hangoutProviderVal = ref.watch(hangoutProvider(uid));
      bool isLoaded = !(haveToWait(hangoutProviderVal));
      if (isLoaded && hangoutProviderVal.asData?.value is Hangout) {
        final Hangout hangout = hangoutProviderVal.asData!.value;
        if (hangout.name.isEmpty) {
          CustomAlertWidget.showBidAlert(
            context,
            WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: HangoutSetting(
                  fromBottomSheet: true,
                ),
              ),
            ),
            isDismissible: false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppbar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              style: TextStyle(color: AppTheme().cardDarkColor),
              autofocus: false,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: Keys.searchUserHint.tr(context),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.text = '';
                          _searchController.clear();
                          ref.watch(searchFilterProvider.state).state =  <String>[];
                        },
                        iconSize: 20,
                        icon: Icon(
                          Icons.close,
                        ),
                      )
                    : IconButton(icon: Container(), onPressed: null),
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                prefixIcon: Icon(Icons.search_rounded),
                // suffixIcon: Icon(Icons.mic),
              ),
              onChanged: (value) {
                value = value.trim();
                ref.watch(searchFilterProvider.state).state = value.isEmpty ? <String>[] : value.split(RegExp(r'\s'));
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(child: _buildContents(context, ref)),
        ],
      ),
    );
  }

  int usersSort(Hangout u1, Hangout u2, List<String> keywords) {
    if (u1.status == 'ONLINE' && u2.status != 'ONLINE') return -1;
    if (u1.status != 'ONLINE' && u2.status == 'ONLINE') return 1;
    // both ONLINE xor OFFLINE
    if (u1.isInMeeting() && !u2.isInMeeting()) return 1;
    if (!u1.isInMeeting() && u2.isInMeeting()) return -1;
    // both inMeeting xor not

    if (keywords.isNotEmpty) {
      final u1Tags = Hangout.tagsFromBio(u1.bio).toSet();
      final u2Tags = Hangout.tagsFromBio(u2.bio).toSet();
      final keywordsSet = keywords.toSet();
      final u1Match = keywordsSet.intersection(u1Tags).length;
      final u2Match = keywordsSet.intersection(u2Tags).length;
      if (u2Match < u1Match) return -1;
      if (u1Match < u2Match) return 1;
    }

    if (u2.rating < u1.rating) return -1;
    if (u1.rating < u2.rating) return 1;

    return -1;
  }

  Widget _buildContents(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider.state).state;
    final mainUserID = ref.watch(myUIDProvider)!;
    var hangoutListProvider = ref.watch(searchUsersStreamProvider);
    if (haveToWait(hangoutListProvider)) {
      return WaitPage(isCupertino: true);
    }
    List<Hangout?> hangoutList = hangoutListProvider.value!;
    hangoutList.removeWhere((element) => element == null);
    hangoutList.removeWhere((element) => element?.id == mainUserID);
    hangoutList.sort((u1, u2) => usersSort(u1!, u2!, filter));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      itemCount: hangoutList.length,
      itemBuilder: (_, index) => UserInfoTile(
        hangout: hangoutList[index]!,
        myUid: mainUserID,
        isForBlockedUser: false,
        marginBottom: 10,
      ),
    );
  }
}
