import 'package:app_2i2i/app/home/wait_page.dart';
import 'package:app_2i2i/app/test_banner.dart';
import 'package:app_2i2i/pages/account/ui/my_account_page.dart';
import 'package:app_2i2i/pages/faq/faq_page.dart';
import 'package:app_2i2i/pages/my_user/my_user_page.dart';
import 'package:app_2i2i/pages/qr_code/qr_code_page.dart';
import 'package:app_2i2i/pages/search_page/ui/search_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('HomePage - build');

    final authStateChanges = ref.watch(authStateChangesProvider);
    if (authStateChanges is AsyncLoading) return WaitPage();

    final myUserLocked = ref.watch(myUserLockedProvider);
    log('HomePage - build - myUserLocked=$myUserLocked');

    return DefaultTabController(
        length: 5,
        child: TestBanner(Scaffold(
          appBar: AppBar(
            leading: IconButton(onPressed: () {
              context.goNamed('app_setting');
            }, icon: Icon(IconData(58751, fontFamily: 'MaterialIcons'))),
            title: Container(
              child: Image.asset(
                'assets/2i2i_letter.png',
                scale: 4,
              ),
              padding: const EdgeInsets.only(left: 10),
            ),
            bottom: const TabBar(
              indicatorColor: Color.fromRGBO(0, 171, 107, 1),
              tabs: [
                Tab(
                  icon: Icon(Icons.search),
                ),
                Tab(
                  icon: Icon(Icons.person),
                ),
                Tab(
                  icon: Icon(Icons.attach_money),
                ),
                Tab(
                  icon: Icon(Icons.help_outline),
                ),
                Tab(
                  icon: Icon(Icons.qr_code_2),
                ),
              ],
            ),
          ),
          body: TabBarView(children: [
            SearchPage(),
            MyUserPage(),
            MyAccountPage(),
            FAQPage(),
            QRCodePage(),
          ]),
        )));
  }
}
