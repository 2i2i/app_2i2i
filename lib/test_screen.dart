import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () async {
              FirebaseFirestore db = FirebaseFirestore.instance;

              final citiesRef = db.collection("cities");

              final ggbData = {"name": "Golden Gate Bridge", "type": "bridge"};
              citiesRef.doc("SF").collection("landmarks").add(ggbData);

              final lohData = {"name": "Legion of Honor", "type": "museum"};
              citiesRef.doc("SF").collection("landmarks").add(lohData);

              final gpData = {"name": "Griffth Park", "type": "park"};
              citiesRef.doc("LA").collection("landmarks").add(gpData);

              final tgData = {"name": "The Getty", "type": "museum"};
              citiesRef.doc("LA").collection("landmarks").add(tgData);

              final lmData = {"name": "Lincoln Memorial", "type": "memorial"};
              citiesRef.doc("DC").collection("landmarks").add(lmData);

              final nasaData = {"name": "National Air and Space Museum", "type": "museum"};
              citiesRef.doc("DC").collection("landmarks").add(nasaData);

              final upData = {"name": "Ueno Park", "type": "park"};
              citiesRef.doc("TOK").collection("landmarks").add(upData);

              final nmData = {"name": "National Musuem of Nature and Science", "type": "museum"};
              citiesRef.doc("TOK").collection("landmarks").add(nmData);

              final jpData = {"name": "Jingshan Park", "type": "park"};
              citiesRef.doc("BJ").collection("landmarks").add(jpData);

              final baoData = {"name": "Beijing Ancient Observatory", "type": "musuem"};
              citiesRef.doc("BJ").collection("landmarks").add(baoData);
            },
            child: Text('data'),
          ),
          SizedBox(height: 100),
          ElevatedButton(
            onPressed: () async {
              FirebaseFirestore db = FirebaseFirestore.instance;
              db.collectionGroup("algorand_accounts").where('id',isEqualTo: 'WEIGBENU56TDSUOQ7JOTZIAJMVZR7JZJEKSD7OPMXQVTAPRS5WIYXRQLDI1').orderBy('ts',descending: true).get().then(
              // db.collectionGroup("algorand_accounts").get().then(
                (res) async {
                    print("Successfully completed \n\n ${res.docs.map((e) => e.data()).toList()}");
                  if(res.docs.isNotEmpty) {
                    print("Successfully completed \n\n ${res.docs.first.reference.path}");
                  }
                },
                onError: (e) {
                  print("Error completing: $e");
                },
              );
            },
            child: Text('Read'),
          ),
        ],
      ),
    );
  }
}
