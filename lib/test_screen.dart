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
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            var map = {
              "active": true,
              "settled": false,
              "A": "9EL9OOeQXRMokpJremS3d5NEoEy1",
              "B": "FtDflBmyV0RiOODCNkDoaSl8au72",
              "addrA": null,
              "addrB": null,
              "energy": {"MAX": 0, "A": null, "CREATOR": null, "B": null},
              "start": null,
              "end": null,
              "duration": null,
              "txns": {},
              "status": "ACCEPTED_B",
              "statusHistory": [
                {"value": "ACCEPTED_B", "ts": "2022-05-03 17:32:42.817857Z"}
              ],
              "net": "testnet",
              "speed": {"num": 0, "assetId": 0},
              "room": null,
              "coinFlowsA": [],
              "coinFlowsB": [],
              "lounge": "chrony",
              "rule": {
                "maxMeetingDuration": 300,
                "minSpeed": 0,
                "importance": {"eccentric": 0, "highroller": 4, "lurker": 0, "chrony": 1}
              },
              "mutedVideoA": false,
              "mutedAudioA": false,
              "mutedAudioB": false,
              "mutedVideoB": false,
            };
            FirebaseFirestore.instance.doc('meetings/Chandresh').set(map);
          },
          child: Text('data'),
        ),
      ),
    );
  }
}
