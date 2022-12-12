import 'dart:async';
import 'dart:ffi';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agora_demo/configs/app_configs.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraManager {
  AgoraManager._();

  static AgoraManager getInstance = AgoraManager._();

  bool localUserJoined = false;
  late RtcEngine agoraEngine;

  final videoFrameController = StreamController<VideoFrame>.broadcast();

  bool isReadyPreview = false;

  AudioFrameObserver audioFrameObserver = AudioFrameObserver(
    onRecordAudioFrame: (String channelId, AudioFrame audioFrame) {
      print(
          "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      // Gets the captured audio frame
    },
    onPlaybackAudioFrame: (String channelId, AudioFrame audioFrame) {
      print(
          "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      // Gets the audio frame for playback
      debugPrint('[onPlaybackAudioFrame] audioFrame: ${audioFrame.toJson()}');
    },
  );

  VideoFrameObserver videoFrameObserver = VideoFrameObserver(
    onCaptureVideoFrame: (VideoFrame videoFrame) {
      print(
          "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      // The video data that this callback gets has not been pre-processed
      // After pre-processing, you can send the processed video data back
      // to the SDK through this callback
      debugPrint('[onCaptureVideoFrame] videoFrame: ${videoFrame.toJson()}');
      final width = videoFrame.width;
      final height = videoFrame.height;
      final yBuffer = videoFrame.yBuffer;
    },
    onRenderVideoFrame:
        (String channelId, int remoteUid, VideoFrame videoFrame) {
      print(
          "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      // Occurs each time the SDK receives a video frame sent by the remote user.
      // In this callback, you can get the video data before encoding.
      // You then process the data according to your particular scenario.
    },
  );

  final onRequireSetState = StreamController<bool>.broadcast();

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
      appId: AppConfigs.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          localUserJoined = true;
          onRequireSetState.add(true);
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.enableVideo();
    await agoraEngine.startPreview();
    isReadyPreview = true;
    onRequireSetState.add(true);
    // Set the format of raw audio data.
    int SAMPLE_RATE = 16000, SAMPLE_NUM_OF_CHANNEL = 1, SAMPLES_PER_CALL = 1024;

    await agoraEngine.setRecordingAudioFrameParameters(
        sampleRate: SAMPLE_RATE,
        channel: SAMPLE_NUM_OF_CHANNEL,
        mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadWrite,
        samplesPerCall: SAMPLES_PER_CALL);
    await agoraEngine.setPlaybackAudioFrameParameters(
        sampleRate: SAMPLE_RATE,
        channel: SAMPLE_NUM_OF_CHANNEL,
        mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadWrite,
        samplesPerCall: SAMPLES_PER_CALL);
    await agoraEngine.setMixedAudioFrameParameters(
        sampleRate: SAMPLE_RATE,
        channel: SAMPLE_NUM_OF_CHANNEL,
        samplesPerCall: SAMPLES_PER_CALL);

    agoraEngine.getMediaEngine().registerAudioFrameObserver(audioFrameObserver);
    agoraEngine.getMediaEngine().registerVideoFrameObserver(videoFrameObserver);

    await Future.delayed(const Duration(seconds: 3));
  }

  void join() {}

  void leave() {}
}
