import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'auth_screen.dart';
import 'auth_screen_web.dart';

class AuthScreenHolder extends ConsumerStatefulWidget {
  final Widget pageChild;

  const AuthScreenHolder({required this.pageChild, Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreenHolder> createState() => _AuthScreenHolderState();
}

class _AuthScreenHolderState extends ConsumerState<AuthScreenHolder> {

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => AuthScreen(pageChild: widget.pageChild, ),
      tablet: (BuildContext context) => AuthScreen(pageChild: widget.pageChild, ),
      desktop: (BuildContext context) => AuthScreenWeb(pageChild: widget.pageChild, ),
    );
  }
}
