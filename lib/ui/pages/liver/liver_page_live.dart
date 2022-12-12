import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agora_demo/configs/app_configs.dart';
import 'package:flutter_agora_demo/ui/pages/agora_manager/agora_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class LiverLivePage extends StatefulWidget {
  const LiverLivePage({Key? key}) : super(key: key);

  @override
  State<LiverLivePage> createState() => _LiverLivePageState();
}

class _LiverLivePageState extends State<LiverLivePage> {
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    subscription =
        AgoraManager.getInstance.onRequireSetState.stream.listen((event) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AgoraManager.getInstance.localUserJoined
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: AgoraManager.getInstance.agoraEngine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
            Row(
              children: [
                TextButton(
                    onPressed: () async {
                      await AgoraManager.getInstance.agoraEngine.stopPreview();
                      setState(() {
                        AgoraManager.getInstance.isReadyPreview = false;
                      });
                      await AgoraManager.getInstance.agoraEngine.joinChannel(
                        token: AppConfigs.liverToken,
                        channelId: AppConfigs.channel,
                        uid: 0,
                        options: const ChannelMediaOptions(
                          defaultVideoStreamType:
                              VideoStreamType.videoStreamHigh,
                        ),
                      );
                      AgoraManager.getInstance.onRequireSetState.add(true);
                    },
                    child: const Text('Join')),
                TextButton(
                  onPressed: () async {
                    await AgoraManager.getInstance.agoraEngine.leaveChannel();
                    AgoraManager.getInstance.localUserJoined = false;
                    await AgoraManager.getInstance.agoraEngine.startPreview();
                    AgoraManager.getInstance.isReadyPreview = true;
                    AgoraManager.getInstance.onRequireSetState.add(true);
                  },
                  child: const Text('Leave'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
