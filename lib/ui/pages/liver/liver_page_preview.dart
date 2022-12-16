import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agora_demo/configs/app_configs.dart';
import 'package:flutter_agora_demo/ui/pages/agora_manager/agora_manager.dart';
import 'package:permission_handler/permission_handler.dart';

import 'liver_page_live.dart';

class LiverPreviewPage extends StatefulWidget {
  const LiverPreviewPage({Key? key}) : super(key: key);

  @override
  State<LiverPreviewPage> createState() => _LiverPreviewPageState();
}

class _LiverPreviewPageState extends State<LiverPreviewPage> {
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    AgoraManager.getInstance.initAgora();
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
              child: AgoraManager.getInstance.isReadyPreview
                  ? Center(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: AgoraManager.getInstance.agoraEngine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.green,
                      height: double.infinity,
                      width: double.infinity,
                    ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LiverLivePage()));
              },
              child: const Text("Open Live"),
            )
          ],
        ),
      ),
    );
  }
}
