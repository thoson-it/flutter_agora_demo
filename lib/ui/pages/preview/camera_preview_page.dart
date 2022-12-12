import 'dart:async';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agora_demo/configs/app_configs.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPreviewPage extends StatefulWidget {
  const CameraPreviewPage({Key? key}) : super(key: key);

  @override
  State<CameraPreviewPage> createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<CameraPreviewPage> {
  late RtcEngine agoraEngine;
  bool _isReadyPreview = false;

  AudioFrameObserver audioFrameObserver = AudioFrameObserver(
    onRecordAudioFrame: (String channelId, AudioFrame audioFrame) {
      // print(
      //     "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      // Gets the captured audio frame
    },
    onPlaybackAudioFrame: (String channelId, AudioFrame audioFrame) {
      // print(
      //     "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      // Gets the audio frame for playback
      // debugPrint('[onPlaybackAudioFrame] audioFrame: ${audioFrame.toJson()}');
    },
  );

  VideoFrameObserver videoFrameObserver = VideoFrameObserver(
    onCaptureVideoFrame: (VideoFrame videoFrame) {
      platform.invokeMethod(
        'process_image',
        {
          'width': videoFrame.width,
          'height': videoFrame.height,
          'yBuffer': videoFrame.yBuffer,
          'uBuffer': videoFrame.uBuffer,
          'vBuffer': videoFrame.vBuffer,
          'yStride': videoFrame.yStride,
          'uStride': videoFrame.uStride,
          'vStride': videoFrame.vStride,
        },
      );
      // _processImage(videoFrame, videoImageController);
      // The video data that this callback gets has not been pre-processed
      // After pre-processing, you can send the processed video data back
      // to the SDK through this callback
    },
    onRenderVideoFrame:
        (String channelId, int remoteUid, VideoFrame videoFrame) {
      // print(
      //     "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      // Occurs each time the SDK receives a video frame sent by the remote user.
      // In this callback, you can get the video data before encoding.
      // You then process the data according to your particular scenario.
    },
  );

  Uint8List? _imageByteData;
  int? _imageWidth;
  int? _imageHeight;

  bool temp = true;

  @override
  void initState() {
    super.initState();
    initAgora();
    eventChannel.receiveBroadcastStream().listen((event) {
      print("ReceiveBroadcastStream ================");
      final map = Map<String, dynamic>.from(event);
      ExternalVideoFrame agoraFrame = ExternalVideoFrame(
          type: VideoBufferType.videoBufferRawData,
          format: VideoPixelFormat.videoPixelRgba,
          buffer: map["byteArray"],
          stride: map["width"],
          height: map["height"],
          timestamp: DateTime.now().millisecondsSinceEpoch);
      agoraEngine.getMediaEngine().pushVideoFrame(frame: agoraFrame);
    });
  }

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
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.enableVideo();

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
    agoraEngine
        .getMediaEngine()
        .setExternalVideoSource(enabled: true, useTexture: false);

    await agoraEngine.startPreview();
    setState(() {
      _isReadyPreview = true;
    });
    await Future.delayed(const Duration(seconds: 3));

    await agoraEngine.joinChannel(
      token: AppConfigs.liverToken,
      channelId: AppConfigs.channel,
      uid: 0,
      options: const ChannelMediaOptions(
        defaultVideoStreamType: VideoStreamType.videoStreamHigh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isReadyPreview
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: agoraEngine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            // SizedBox(
            //   height: 300,
            //   width: double.infinity,
            //   child: StreamBuilder<Image>(
            //     stream: videoImageController.stream,
            //     builder: (context, snap) {
            //       return snap.data ?? Container(color: Colors.red,);
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

const platform = MethodChannel('it.thoson/image');
const eventChannel = EventChannel('it.thoson/image_stream');

final videoImageController = StreamController<Image>.broadcast();

Future<Image?> _processImage(
    VideoFrame videoFrame, StreamController<Image> controller) async {
  platform.invokeMethod(
    'process_image',
    {
      'width': videoFrame.width,
      'height': videoFrame.height,
      'yBuffer': videoFrame.yBuffer,
      'uBuffer': videoFrame.uBuffer,
      'vBuffer': videoFrame.vBuffer,
      'yStride': videoFrame.yStride,
      'uStride': videoFrame.uStride,
      'vStride': videoFrame.vStride,
    },
  );
  //
  // print("ABCXYZ: $result");
  // final map = Map<String, dynamic>.from(result);
  // final image = Image.memory(
  //   map["byteArray"],
  //   width: 100,
  //   height: 100,
  //   fit: BoxFit.contain,
  // );
  // controller.sink.add(image);
  return null;
}
