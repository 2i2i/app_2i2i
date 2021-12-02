import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/pages/account/ui/my_account_page.dart';
import 'package:app_2i2i/pages/app/test_banner.dart';
import 'package:app_2i2i/pages/faq/faq_page.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/my_user/ui/my_user_page.dart';
import 'package:app_2i2i/pages/qr_code/qr_code_page.dart';
import 'package:app_2i2i/pages/search_page/ui/search_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    log('HomePage - build');
    final authStateChanges = ref.watch(authStateChangesProvider);
    if (authStateChanges is AsyncLoading) return WaitPage();

    final myUserLocked = ref.watch(myUserLockedProvider);
    log('HomePage - build - myUserLocked=$myUserLocked');

    return DefaultTabController(
      length: 5,
      child: TestBanner(
        widget: Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme().lightGray,
            leading: IconButton(
                onPressed: () {
                  context.pushNamed('app_setting');
                },
                icon: Icon(IconData(58751, fontFamily: 'MaterialIcons'),
                    color: AppTheme().black)),
            centerTitle: true,
            title:
                Image.asset('assets/logo.png', height: 30, fit: BoxFit.contain),
          ),
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                padding: EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                    color: AppTheme().lightBeige,
                    borderRadius: BorderRadius.circular(10)),
                child: TabBar(
                  indicatorColor: AppTheme().primaryColor,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.search_rounded, color: AppTheme().black),
                    ),
                    Tab(
                      icon:
                          Icon(Icons.person_outlined, color: AppTheme().black),
                    ),
                    Tab(
                      icon: Icon(Icons.attach_money_rounded,
                          color: AppTheme().black),
                    ),
                    Tab(
                      icon: Icon(Icons.help_outline_rounded,
                          color: AppTheme().black),
                    ),
                    Tab(
                      icon: Icon(Icons.qr_code_2_rounded,
                          color: AppTheme().black),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(children: [
                  SearchPage(),
                  MyUserPage(),
                  MyAccountPage(),
                  FAQPage(),
                  QRCodePage(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
