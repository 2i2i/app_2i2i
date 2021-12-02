import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWidget extends ConsumerWidget {
  AuthWidget({required this.homePageBuilder, required this.setupPageBuilder});

  final WidgetBuilder homePageBuilder;
  final WidgetBuilder setupPageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('AuthWidget - build');
    final authStateChanges = ref.watch(authStateChangesProvider);
    log('AuthWidget - build - authStateChanges=$authStateChanges');
    return authStateChanges.when(data: (user) {
      log('AuthWidget - build - authStateChanges.when - data - user=$user');
      if (user == null) {
        return setupPageBuilder(context);
      }
      log('AuthWidget - build - authStateChanges.when - data - 2');
      final signUpViewModel = ref.read(setupUserViewModelProvider);
      log('AuthWidget - build - authStateChanges.when - data - signUpViewModel=$signUpViewModel');
      if (!signUpViewModel.signUpInProcess) {
        return homePageBuilder(context);
      }
      log('AuthWidget - build - authStateChanges.when - data - 3');
      return setupPageBuilder(context);
    }, loading: () {
      log('AuthWidget - build - authStateChanges.when - loading');
      return  WaitPage();
    }, error: (_, __) {
      log('AuthWidget - build - authStateChanges.when - error');
      return const Scaffold(
        body: Center(
          child: Text('error'),
        ),
      );
    });
  }
}
