import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agora_demo/configs/app_configs.dart';
import 'package:flutter_agora_demo/ui/pages/agora_manager/agora_manager.dart';
import 'package:flutter_agora_demo/ui/pages/liver/liver_page_preview.dart';
import 'package:permission_handler/permission_handler.dart';

class LiverPage extends StatefulWidget {
  const LiverPage({Key? key}) : super(key: key);

  @override
  State<LiverPage> createState() => _LiverPageState();
}

class _LiverPageState extends State<LiverPage> {
  @override
  void initState() {
    super.initState();
    // AgoraManager.getInstance.initAgora();
    // AgoraManager.getInstance.onRequireSetState.stream.listen((event) {
    //   if (!mounted) return;
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LiverPreviewPage()));
              },
              child: const Text("Open preview"),
            )
            // Expanded(
            //   child: AgoraManager.getInstance.localUserJoined
            //       ? AgoraVideoView(
            //           controller: VideoViewController(
            //             rtcEngine: AgoraManager.getInstance.agoraEngine,
            //             canvas: const VideoCanvas(uid: 0),
            //           ),
            //         )
            //       : const CircularProgressIndicator(),
            // ),
            // Row(
            //   children: [
            //     TextButton(
            //         onPressed: () async {
            //           await AgoraManager.getInstance.agoraEngine.stopPreview();
            //           setState(() {
            //             AgoraManager.getInstance.isReadyPreview = false;
            //           });
            //           await AgoraManager.getInstance.agoraEngine.joinChannel(
            //             token: AppConfigs.liverToken,
            //             channelId: AppConfigs.channel,
            //             uid: 0,
            //             options: const ChannelMediaOptions(
            //               defaultVideoStreamType:
            //                   VideoStreamType.videoStreamHigh,
            //             ),
            //           );
            //         },
            //         child: Text('Join')),
            //     TextButton(
            //         onPressed: () async {
            //           await AgoraManager.getInstance.agoraEngine.leaveChannel();
            //           AgoraManager.getInstance.localUserJoined = false;
            //           await AgoraManager.getInstance.agoraEngine.startPreview();
            //           AgoraManager.getInstance.isReadyPreview = true;
            //         },
            //         child: Text('Leave')),
            //   ],
            // ),
            // SizedBox(
            //   height: 300,
            //   width: double.infinity,
            //   child: AgoraManager.getInstance.isReadyPreview
            //       ? AgoraVideoView(
            //           controller: VideoViewController(
            //             rtcEngine: AgoraManager.getInstance.agoraEngine,
            //             canvas: const VideoCanvas(uid: 0),
            //           ),
            //         )
            //       : Container(
            //           color: Colors.green,
            //           height: 300,
            //           width: double.infinity,
            //         ),
            // ),
          ],
        ),
      ),
    );
  }
}
