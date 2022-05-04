// class MeetingStatusModel {
//   bool mutedVideoA = false;
//   bool mutedVideoB = false;
//   bool mutedAudioA = false;
//   bool mutedAudioB = false;
//
//   MeetingStatusModel({
//     this.mutedVideoA = false,
//     this.mutedVideoB = false,
//     this.mutedAudioA = false,
//     this.mutedAudioB = false,
//   });
//
//   factory MeetingStatusModel.fromMap(
//       Map<String, dynamic> data) {
//     final mutedVideoA = data['mutedVideoA'];
//     final mutedVideoB = data['mutedVideoB'];
//     final mutedAudioA = data['mutedAudioA'];
//     final mutedAudioB = data['mutedAudioB'];
//
//     return MeetingStatusModel(
//       mutedVideoA: mutedVideoA,
//       mutedVideoB: mutedVideoB,
//       mutedAudioA: mutedAudioA,
//       mutedAudioB: mutedAudioB,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     final data = new Map<String, dynamic>();
//     data['mutedVideoA'] = mutedVideoA;
//     data['mutedVideoB'] = mutedVideoB;
//     data['mutedAudioA'] = mutedAudioA;
//     data['mutedAudioB'] = mutedAudioB;
//     return data;
//   }
// }
