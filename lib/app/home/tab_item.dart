import 'package:flutter/material.dart';
import 'package:app_2i2i/constants/keys.dart';
import 'package:app_2i2i/constants/strings.dart';

enum TabItem { search, myAccount, bidsIn }

class TabItemData {
  const TabItemData(
      {required this.key, required this.title, required this.icon});

  final String key;
  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.search: TabItemData(
      key: Keys.searchTab,
      title: Strings.search,
      icon: Icons.work,
    ),
    TabItem.myAccount: TabItemData(
      key: Keys.myAccountTab,
      title: Strings.myAccount,
      icon: Icons.view_headline,
    ),
    TabItem.bidsIn: TabItemData(
      key: Keys.bidsInTab,
      title: Strings.bidsIn,
      icon: Icons.person,
    ),
  };
}
