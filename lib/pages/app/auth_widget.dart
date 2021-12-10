import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWidget extends ConsumerWidget {
  AuthWidget({required this.homePageBuilder, required this.setupPageBuilder});

  final WidgetBuilder homePageBuilder;
  final WidgetBuilder setupPageBuilder;


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authStateChanges = ref.watch(authStateChangesProvider);

    return authStateChanges.when(data: (user) {
      if (user == null) {
        final signUpViewModel = ref.read(setupUserViewModelProvider);
        if (!signUpViewModel.signUpInProcess) {
          Future.delayed(Duration.zero).then((value) {
            ref.read(setupUserViewModelProvider).createAuthAndStartAlgorand();
          });
        }
        return WaitPage();
        // return setupPageBuilder(context);
      }

      final signUpViewModel = ref.read(setupUserViewModelProvider);
      if (!signUpViewModel.signUpInProcess) {
        return homePageBuilder(context);
      }
      return setupPageBuilder(context);
    }, loading: () {
      return  WaitPage();
    }, error: (_, __) {
      return const Scaffold(
        body: Center(
          child: Text('error'),
        ),
      );
    });
  }
}
