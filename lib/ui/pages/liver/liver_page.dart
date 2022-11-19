import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agora_demo/configs/app_configs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:processing_camera_image/processing_camera_image.dart';
import 'package:image/image.dart' as imglib;

class LiverPage extends StatefulWidget {
  const LiverPage({Key? key}) : super(key: key);

  @override
  State<LiverPage> createState() => _LiverPageState();
}

class _LiverPageState extends State<LiverPage> {
  bool _localUserJoined = false;
  late RtcEngine _engine;

  final videoFrameController = StreamController<VideoFrame>.broadcast();

  final ProcessingCameraImage _processingCameraImage = ProcessingCameraImage();
  imglib.Image? currentImage;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: AppConfigs.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: AppConfigs.liverToken,
      channelId: AppConfigs.channel,
      uid: 0,
      options: const ChannelMediaOptions(
        defaultVideoStreamType: VideoStreamType.videoStreamHigh,
      ),
    );

    VideoFrameObserver videoFrameObserver = VideoFrameObserver(
        onCaptureVideoFrame: (VideoFrame videoFrame) {
      // The video data that this callback gets has not been pre-processed
      // After pre-processing, you can send the processed video data back
      // to the SDK through this callback
      debugPrint('[onCaptureVideoFrame] videoFrame: ${videoFrame.toJson()}');
      // videoFrameController.add(videoFrame);
    }, onRenderVideoFrame:
            (String channelId, int remoteUid, VideoFrame videoFrame) {
      // Occurs each time the SDK receives a video frame sent by the remote user.
      // In this callback, you can get the video data before encoding.
      // You then process the data according to your particular scenario.
    });

    _engine.getMediaEngine().registerVideoFrameObserver(videoFrameObserver);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _localUserJoined
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
            Container(
              height: 200,
              child: StreamBuilder<VideoFrame>(
                stream: videoFrameController.stream,
                initialData: null,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  final image = _processingCameraImage.processCameraImageToGray(
                    width: data?.width,
                    height: data?.height,
                    plane0: data?.uBuffer,
                  );
                  if (image != null) {
                    currentImage = image;
                  }
                  return Container(
                    color: Colors.red,
                    width: double.infinity,
                    height: double.infinity,
                    child: Text(data?.toJson().toString() ?? ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
