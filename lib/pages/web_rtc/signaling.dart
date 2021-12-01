// inspired by:
// https://webrtc.org/getting-started/firebase-rtc-codelab

import 'dart:convert';

import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  Signaling(
      {required this.meeting,
      required this.amA,
      required this.localVideo,
      required this.remoteVideo}) {
    log('Signaling - ${meeting.id}');

    CollectionReference rooms = FirebaseFirestore.instance
        .collection('meetings')
        .doc(meeting.id)
        .collection(meeting.A + '-' + meeting.B);
    log('Signaling - amA=$amA');
    if (amA) {
      // A creates new room
      roomRef = rooms.doc();

      initAsA();
    } else {
      // B joins created currentRoom
      roomRef = rooms.doc(meeting.currentRoom);

      initAsB();
    }

    log('Signaling - ${meeting.id} - roomRef=$roomRef');
  }
  void initAsA() async {
    log('Signaling - initAsA - ${meeting.id}');
    await openUserMedia();
    await createRoom();
    await notifyMeeting();
  }

  void initAsB() async {
    log('Signaling - initAsB - ${meeting.id}');
    await openUserMedia();
    await joinRoom();
  }

  Future notifyMeeting() async {
    log('Signaling - notifyMeeting - ${meeting.id}');
    final meetingRoomCreated =
        FirebaseFunctions.instance.httpsCallable('meetingRoomCreated');
    await meetingRoomCreated(
        {'meetingId': meeting.id, 'currentRoom': roomRef.id});
  }

  final Meeting meeting;
  final bool amA;
  final RTCVideoRenderer localVideo;
  final RTCVideoRenderer remoteVideo;
  late final DocumentReference roomRef;

  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  RTCPeerConnection? peerConnection;
  late MediaStream localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;

  Future<void> createRoom() async {
    log('Signaling - createRoom - ${meeting.id}');

    log('Create PeerConnection with configuration: $configuration');

    peerConnection = await createPeerConnection(configuration);
    // log('peerConnection=${peerConnection.toString()}');

    registerPeerConnectionListeners();

    log('localStream=$localStream');
    localStream.getTracks().forEach((track) {
      log('localStream?.getTracks().forEach');
      peerConnection?.addTrack(track, localStream);
    });

    // Code for collecting ICE candidates below
    final iceCandidatesCollection = roomRef.collection('iceCandidatesA');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      log('Got candidate: ${candidate.toMap()}');
      iceCandidatesCollection.add(candidate.toMap());
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    log('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {
      'offer': offer.toMap(),
      'A': meeting.A,
      'B': meeting.B,
    };

    await roomRef.set(roomWithOffer);

    peerConnection?.onTrack = (RTCTrackEvent event) {
      log('Got remote track: event.streams.length=${event.streams.length}');
      for (int i = 0; i < event.streams.length; i++) {
      }

      event.streams[0].getTracks().forEach((track) {
        log('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    // Listening for remote session description below
    roomRef.snapshots().listen((snapshot) async {
      log('Got updated room: ${snapshot.data()}');

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        final answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        log("Someone tried to connect");
        await peerConnection?.setRemoteDescription(answer);
      }
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    roomRef.collection('iceCandidatesB').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          log('Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });
    // Listen for remote ICE candidates above

    // return roomId;
  }

  Future<void> joinRoom() async {
    log('Signaling - joinRoom - ${meeting.id}');

    final roomSnapshot = await roomRef.get();
    log('Got room ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      log('Create PeerConnection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners();

      localStream.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream);
      });

      // Code for collecting ICE candidates below
      final iceCandidatesCollection = roomRef.collection('iceCandidatesB');
      peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        log('onIceCandidate: ${candidate.toMap()}');
        iceCandidatesCollection.add(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      peerConnection?.onTrack = (RTCTrackEvent event) {
        log('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          log('Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });
      };


        // Code for creating SDP answer below
        final data = (roomSnapshot.data()??{}) as Map<String, dynamic>;
        log(F+' Got offer $data');
        final offer = data['offer']??{};
        await peerConnection?.setRemoteDescription(
            RTCSessionDescription(offer['sdp'], offer['type']),
        );

      final answer = await peerConnection?.createAnswer();
      log('Created Answer $answer');

      if(answer!= null) {
        await peerConnection?.setLocalDescription(answer);

        Map<String, dynamic> roomWithAnswer = {
          'answer': {'type': answer.type, 'sdp': answer.sdp}
        };

        await roomRef.update(roomWithAnswer);
        // Finished creating SDP answer
      }





      // Listening for remote ICE candidates below
      roomRef.collection('iceCandidatesA').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          final data = document.doc.data() as Map<String, dynamic>;
          log('Got new remote ICE candidate: $data');
          peerConnection?.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        });
      });
    }
  }

  Future<void> openUserMedia() async {
    log('Signaling - openUserMedia - ${meeting.id}');

    final stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  Future<void> hangUp(RTCVideoRenderer localVideo, {String? reason}) async {
    try {
      log('Signaling - hangUp - ${meeting.id}');

      final endMeeting = FirebaseFunctions.instance.httpsCallable('endMeeting');
      final args = {
        'meetingId': meeting.id,
      };
      if (reason != null) args['reason'] = reason;
      await endMeeting(args);

      log('Signaling - hangUp - ${meeting.id} - localVideo.srcObject=${localVideo.srcObject}');
      List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
      tracks.forEach((track) {
        track.stop();
      });

      log('Signaling - hangUp - ${meeting.id} - local track.stop');

      if (remoteStream != null) {
        remoteStream!.getTracks().forEach((track) => track.stop());
      }
      log('Signaling - hangUp - ${meeting.id} - remote track.stop');

      if (peerConnection != null) peerConnection!.close();
      log('Signaling - hangUp - ${meeting.id} - peerConnection!.close()');

      // if (roomId != null) {
      final iceCandidatesB = await roomRef.collection('iceCandidatesB').get();
      iceCandidatesB.docs.forEach((document) => document.reference.delete());

      final iceCandidatesA = await roomRef.collection('iceCandidatesA').get();
      iceCandidatesA.docs.forEach((document) => document.reference.delete());

      await roomRef.delete();
      log('Signaling - hangUp - ${meeting.id} - room deleted');
      // }

      localStream.dispose();
      log('Signaling - hangUp - ${meeting.id} - localStream.dispose');
      remoteStream?.dispose();
      log('Signaling - hangUp - ${meeting.id} - remoteStream?.dispose');
    } catch (e) {
      print(e);
    }
  }

  void registerPeerConnectionListeners() {
    log('Signaling - registerPeerConnectionListeners - ${meeting.id}');

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      log('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) async {
      log('Connection state change: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
      }
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) async {
      log('Signaling state change: $state');
      if (state == RTCSignalingState.RTCSignalingStateClosed) {
      }
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      log('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      log("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
