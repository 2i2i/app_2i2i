import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoInternetScreen extends ConsumerStatefulWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(kRadialReactionRadius),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/no_internet.png',
                height: kToolbarHeight,
                width: kToolbarHeight * 2,
                fit: BoxFit.contain),
            SizedBox(height: kRadialReactionRadius),
            Text('No Internet Connection',
                style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 12),
            Text(
                'You are not connected to the internet. Make sure WI-FI is on. Airplane Mode is off and try again',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2),
          ],
        ),
      ),
    );
  }
}
