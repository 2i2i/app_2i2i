

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/models/meeting_model.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  Signaling(
      {required this.meeting,
      required this.amA,
      required this.localVideo,
      required this.remoteVideo}) {
    log(G + 'Signaling - ${meeting.id}');

    CollectionReference rooms = FirebaseFirestore.instance
        .collection('meetings')
        .doc(meeting.id)
        .collection(meeting.A + '-' + meeting.B);
    log(G + 'Signaling - amA=$amA');
    if (amA) {
      // A creates new room
      roomRef = rooms.doc();

      initAsA();
    } else {
      // B joins created currentRoom
      roomRef = rooms.doc(meeting.room);

      initAsB();
    }

    log(G + 'Signaling - ${meeting.id} - roomRef=$roomRef');
  }
  void initAsA() async {
    log(G + 'Signaling - initAsA - ${meeting.id}');
    await openUserMedia();
    await createRoom();
    await notifyMeeting();
  }

  void initAsB() async {
    log(G + 'Signaling - initAsB - ${meeting.id}');
    await openUserMedia();
    await joinRoom();
  }

  Future notifyMeeting() async {
    log(G + 'Signaling - notifyMeeting - ${meeting.id}');
    final advanceMeeting =
        FirebaseFunctions.instance.httpsCallable('advanceMeeting');
    await advanceMeeting({
      'meetingId': meeting.id,
      'room': roomRef.id,
      'reason': MeetingStatus.ROOM_CREATED.toStringEnum()
    });
  }

  final Meeting meeting;
  final bool amA;
  final RTCVideoRenderer localVideo;
  final RTCVideoRenderer remoteVideo;
  late final DocumentReference roomRef;
  List<MediaDeviceInfo>? cameras;

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
    log(G + 'Signaling - createRoom - ${meeting.id}');

    log(G + 'Create PeerConnection with configuration: $configuration');

    peerConnection = await createPeerConnection(configuration);
    // log(G +'peerConnection=${peerConnection.toString()}');

    registerPeerConnectionListeners();

    log(G + 'localStream=$localStream');
    localStream.getTracks().forEach((track) {
      log(G + 'localStream?.getTracks().forEach');
      peerConnection?.addTrack(track, localStream);
    });

    // Code for collecting ICE candidates below
    final iceCandidatesCollection = roomRef.collection('iceCandidatesA');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      log(G + 'Got candidate: ${candidate.toMap()}');
      iceCandidatesCollection.add(candidate.toMap());
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    log(G + 'Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {
      'offer': offer.toMap(),
      'A': meeting.A,
      'B': meeting.B,
    };

    await roomRef.set(roomWithOffer);

    peerConnection?.onTrack = (RTCTrackEvent event) {
      log(G + 'Got remote track: event.streams.length=${event.streams.length}');
      // for (int i = 0; i < event.streams.length; i++) {}

      event.streams[0].getTracks().forEach((track) {
        log(G + 'Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });

      final advanceMeeting =
          FirebaseFunctions.instance.httpsCallable('advanceMeeting');
      final newStatus = amA
          ? MeetingStatus.A_RECEIVED_REMOTE
          : MeetingStatus.B_RECEIVED_REMOTE;
      log(I + 'Got remote track: amA=$amA + newStatus=$newStatus');
      advanceMeeting({
        'meetingId': meeting.id,
        'reason': newStatus.toStringEnum(),
      });
    };

    // Listening for remote session description below
    roomRef.snapshots().listen((snapshot) async {
      log(G + 'Got updated room: ${snapshot.data()}');

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        final answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        log(G + "Someone tried to connect");
        await peerConnection?.setRemoteDescription(answer);
      }
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    roomRef.collection('iceCandidatesB').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          log(G + 'Got new remote ICE candidate: ${jsonEncode(data)}');
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
    log(G + 'Signaling - joinRoom - ${meeting.id}');

    final roomSnapshot = await roomRef.get();
    log(G + 'Got room ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      log(G + 'Create PeerConnection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners();

      localStream.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream);
      });

      // Code for collecting ICE candidates below
      final iceCandidatesCollection = roomRef.collection('iceCandidatesB');
      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        log(G + 'onIceCandidate: ${candidate.toMap()}');
        iceCandidatesCollection.add(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      peerConnection?.onTrack = (RTCTrackEvent event) {
        log(G + 'Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          log(G + 'Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });

        final advanceMeeting =
            FirebaseFunctions.instance.httpsCallable('advanceMeeting');
        final newStatus = amA
            ? MeetingStatus.A_RECEIVED_REMOTE
            : MeetingStatus.B_RECEIVED_REMOTE;
        log(I + 'Got remote track: amA=$amA + newStatus=$newStatus');
        advanceMeeting({
          'meetingId': meeting.id,
          'reason': newStatus.toStringEnum(),
        });
      };

      // Code for creating SDP answer below
      final data = roomSnapshot.data() as Map<String, dynamic>;
      log('Got offer $data');
      final offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      final answer = await peerConnection!.createAnswer();
      log(G + 'Created Answer $answer');

      await peerConnection!.setLocalDescription(answer);
      // if (answer != null) {

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await roomRef.update(roomWithAnswer);
      // Finished creating SDP answer
      // }

      // Listening for remote ICE candidates below
      roomRef.collection('iceCandidatesA').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          final data = document.doc.data() as Map<String, dynamic>;
          log(G + 'Got new remote ICE candidate: $data');
          peerConnection!.addCandidate(
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
    try {
      log(G + 'Signaling - openUserMedia - ${meeting.id}');

      final stream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
      cameras = await Helper.cameras;
      localVideo.srcObject = stream;
      localStream = stream;

      remoteVideo.srcObject = await createLocalMediaStream('key');
    } catch (e) {
      print(e);
    }
  }

  Future<void> hangUp(RTCVideoRenderer localVideo,
      {required MeetingStatus reason}) async {
    try {
      log(G + 'Signaling - hangUp - ${meeting.id}');
      final endMeeting = FirebaseFunctions.instance.httpsCallable('endMeeting');
      final args = {
        'meetingId': meeting.id,
        'reason': reason.toStringEnum(),
      };
      await endMeeting(args);

      //Close Local A
      if (localVideo.srcObject != null) {
        List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
        localVideo.srcObject!.getVideoTracks()[0].stop();
        // tracks.forEach((track) => track.stop());
        localVideo.srcObject = null;
        await localVideo.dispose();
      }

      //Close Remote B
      if (remoteStream != null) {
        List<MediaStreamTrack> tracks = remoteStream!.getTracks();
        remoteStream!.getVideoTracks()[0].stop();
        // tracks.forEach((track) => track.stop());
        await remoteStream!.dispose();
      }

      if (peerConnection != null) {
        peerConnection!.close();
      }

      remoteVideo.srcObject = null;
      localVideo.srcObject = null;
    } catch (e) {
      log(e.toString());
    }
  }

  void registerPeerConnectionListeners() {
    log(G + 'Signaling - registerPeerConnectionListeners - ${meeting.id}');

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      log(G + 'ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) async {
      log(G + 'Connection state change: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {}
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) async {
      log(G + 'Signaling state change: $state');
      if (state == RTCSignalingState.RTCSignalingStateClosed) {}
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      log(G + 'ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      log(G + "Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
