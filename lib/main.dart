import 'package:flutter/material.dart';
import 'package:flutter_agora_demo/ui/pages/live/live_page.dart';
import 'package:flutter_agora_demo/utils/user_type.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialSetup();
  }

  void initialSetup() async {
    await [Permission.camera, Permission.microphone].request();
    print("Request permission");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const LivePage(userType: UserType.liver)));
              },
              child: const Text("Liver"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const LivePage(userType: UserType.viewer)));
              },
              child: const Text("Viewer"),
            ),
          ],
        ),
      ),
    );
  }
}
