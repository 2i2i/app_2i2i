import 'package:flutter/material.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('App Bar'),
        actions: [
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.add),
          )
        ],
      ),
      /*body: SvgPicture.asset(
        'assets/splash_bg.svg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),*/
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(onPressed: (){}, child: Text('OutlinedButton')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: (){}, child: Text('ElevatedButton')),
            SizedBox(height: 20),
            TextButton(onPressed: (){}, child: Text('TextButton')),
            SizedBox(height: 20),
            ElevatedButton.icon(onPressed: (){}, icon: Icon(Icons.add), label: Text('ElevatedButton.icon')),
            SizedBox(height: 20),
            Text('Headline 6',style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 10),
            Text('Headline 5',style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 10),
            Text('Headline 4',style: Theme.of(context).textTheme.headline4),
            SizedBox(height: 10),
            Text('Headline 3',style: Theme.of(context).textTheme.headline3),
            SizedBox(height: 10),
            Text('Headline 2',style: Theme.of(context).textTheme.headline2),
            SizedBox(height: 10),
            Text('Headline 1',style: Theme.of(context).textTheme.headline1),
            SizedBox(height: 10),
            Text('subtitle 2',style: Theme.of(context).textTheme.subtitle2),
            SizedBox(height: 10),
            Text('subtitle 1',style: Theme.of(context).textTheme.subtitle1),
            SizedBox(height: 10),
            Text('bodyText 2',style: Theme.of(context).textTheme.bodyText2),
            SizedBox(height: 10),
            Text('bodyText 1',style: Theme.of(context).textTheme.bodyText1),
            SizedBox(height: 10),
            Text('caption',style: Theme.of(context).textTheme.caption),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: Icon(Icons.add),
      ),
    );
  }
}