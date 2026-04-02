import 'package:equatable/equatable.dart';

class MeetingResponse extends Equatable {
  final String status;
  final String message;
  final MeetingData data;

  const MeetingResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MeetingResponse.fromJson(Map<String, dynamic> json) {
    return MeetingResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: MeetingData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [status, message, data];
}

class MeetingData extends Equatable {
  final Meeting meeting;
  final Attendee attendee;

  const MeetingData({
    required this.meeting,
    required this.attendee,
  });

  factory MeetingData.fromJson(Map<String, dynamic> json) {
    return MeetingData(
      meeting: Meeting.fromJson(json['meeting'] as Map<String, dynamic>),
      attendee: Attendee.fromJson(json['attendee'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [meeting, attendee];
}

class Meeting extends Equatable {
  final String meetingId;
  final String? externalMeetingId;
  final String? mediaRegion;
  final MediaPlacement? mediaPlacement;

  const Meeting({
    required this.meetingId,
    this.externalMeetingId,
    this.mediaRegion,
    this.mediaPlacement,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      meetingId: json['MeetingId'] as String,
      externalMeetingId: json['ExternalMeetingId'] as String?,
      mediaRegion: json['MediaRegion'] as String?,
      mediaPlacement: json['MediaPlacement'] != null
          ? MediaPlacement.fromJson(json['MediaPlacement'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [meetingId, externalMeetingId, mediaRegion, mediaPlacement];
}

class MediaPlacement extends Equatable {
  final String audioHostUrl;
  final String audioFallbackUrl;
  final String signalingUrl;
  final String turnControlUrl;
  final String screenDataUrl;
  final String screenViewingUrl;
  final String screenSharingUrl;
  final String eventIngestionUrl;

  const MediaPlacement({
    required this.audioHostUrl,
    required this.audioFallbackUrl,
    required this.signalingUrl,
    required this.turnControlUrl,
    required this.screenDataUrl,
    required this.screenViewingUrl,
    required this.screenSharingUrl,
    required this.eventIngestionUrl,
  });

  factory MediaPlacement.fromJson(Map<String, dynamic> json) {
    return MediaPlacement(
      audioHostUrl: json['AudioHostUrl'] as String,
      audioFallbackUrl: json['AudioFallbackUrl'] as String,
      signalingUrl: json['SignalingUrl'] as String,
      turnControlUrl: json['TurnControlUrl'] as String,
      screenDataUrl: json['ScreenDataUrl'] as String,
      screenViewingUrl: json['ScreenViewingUrl'] as String,
      screenSharingUrl: json['ScreenSharingUrl'] as String,
      eventIngestionUrl: json['EventIngestionUrl'] as String,
    );
  }

  @override
  List<Object?> get props => [
        audioHostUrl,
        audioFallbackUrl,
        signalingUrl,
        turnControlUrl,
        screenDataUrl,
        screenViewingUrl,
        screenSharingUrl,
        eventIngestionUrl,
      ];
}

class Attendee extends Equatable {
  final String externalUserId;
  final String attendeeId;
  final String joinToken;
  final Capabilities capabilities;

  const Attendee({
    required this.externalUserId,
    required this.attendeeId,
    required this.joinToken,
    required this.capabilities,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      externalUserId: json['ExternalUserId'] as String,
      attendeeId: json['AttendeeId'] as String,
      joinToken: json['JoinToken'] as String,
      capabilities: Capabilities.fromJson(json['Capabilities'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [externalUserId, attendeeId, joinToken, capabilities];
}

class Capabilities extends Equatable {
  final String audio;
  final String video;
  final String content;

  const Capabilities({
    required this.audio,
    required this.video,
    required this.content,
  });

  factory Capabilities.fromJson(Map<String, dynamic> json) {
    return Capabilities(
      audio: json['Audio'] as String,
      video: json['Video'] as String,
      content: json['Content'] as String,
    );
  }

  @override
  List<Object?> get props => [audio, video, content];
}
