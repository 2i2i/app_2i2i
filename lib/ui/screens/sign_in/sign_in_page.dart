import 'package:app_2i2i/ui/screens/sign_in/bg_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    height: kToolbarHeight * 2.25,
                    width: kToolbarHeight * 2.25,
                  ),
                  SizedBox(height: kToolbarHeight),
                  Text(
                    'The place for you to Hangout',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 8),
                  Text(
                      '2i2i provides a safe and private space for Guests and Host to meet in the form of video calls',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption),
                  SizedBox(height: 8),
                  Text(
                      '>305 MEETINGS SINCE LAUNCH',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.overline?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold
                      )),
                ],
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: ListTile(
                dense: true,
                leading: Image.asset('assets/google.png',height: 30,width: 30),
                title: Text('Login with Google'),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(child: Divider(),width: kToolbarHeight),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                    child: Text('OR',style: Theme.of(context).textTheme.caption),
                  ),
                  Container(child: Divider(),width: kToolbarHeight),
                ],
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: ListTile(
                dense: true,
                leading: Image.asset('assets/twitter.png',height: 30,width: 30),
                title: Text('Login with Twitter'),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(child: Divider(),width: kToolbarHeight),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                    child: Text('OR',style: Theme.of(context).textTheme.caption),
                  ),
                  Container(child: Divider(),width: kToolbarHeight),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {},
                child: Text('Login as Guest',
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                    )),
              ),
            ),
            SizedBox(height: kToolbarHeight*1.25),
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'About ',
                  style: Theme.of(context).textTheme.caption,
                  children: <TextSpan>[
                    TextSpan(
                        text: '2i2i',
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary,
                          decoration: TextDecoration.underline
                        )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
