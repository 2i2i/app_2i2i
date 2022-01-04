import 'package:flutter/material.dart';

class HipPage extends StatefulWidget {
  const HipPage({Key? key}) : super(key: key);

  @override
  _HipPageState createState() => _HipPageState();
}

class _HipPageState extends State<HipPage> with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            title: Text("Silver AppBar With ToolBar"),
            pinned: true,
            expandedHeight: 160.0,
            bottom: new TabBar(
              tabs: [
                new Tab(text: 'Tab 1'),
                new Tab(text: 'Tab 2'),
                new Tab(text: 'Tab 3'),
              ],
              controller: controller,
            ),
          ),
          new SliverFillRemaining(
            child: TabBarView(
              controller: controller,
              children: <Widget>[
                Text("Tab 1"),
                Text("Tab 2"),
                Text("Tab 3"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}