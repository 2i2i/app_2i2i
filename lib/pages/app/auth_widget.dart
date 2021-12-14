import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWidget extends ConsumerWidget {
  AuthWidget({required this.homePageBuilder});

  final WidgetBuilder homePageBuilder;


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

      return homePageBuilder(context);
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
