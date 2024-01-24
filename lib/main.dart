import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';

const appId = "27735452d0b14d63a7cf768457ec5f9f";
const token =
    "007eJxTYMg0EFrgUDzj9W1dLkHPkn+t+cJvZrVc2r1x/ozGmWtutbkpMBiZmxubmpgapRgkGZqkmBknmienmZtZmJiapyabplmmRb7akNoQyMhgfpWTiZEBAkF8VoaS1OISQwYGAHjJIBI=";
int? _remoteUid;
late RtcEngine _engine;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    initAgora();
    super.initState();
  }

  Future<void> initAgora() async {
    _engine = await RtcEngine.create(appId);
    await [Permission.microphone, Permission.camera].request();
    await _engine.enableVideo();
    _engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (String channel, int uid, int elapsed) {
        print("local user $uid joined");
      },
      userJoined: (int uid, int elapsed) {
        print("remote user $uid joined");
        setState(() {
          _remoteUid = uid;
        });
      },
      userOffline: (int uid, UserOfflineReason reason) {
        print("remote user $uid left channel");
        setState(() {
          _remoteUid = null;
        });
      },
    ));
    await _engine.joinChannel(token, "test1", null, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Video Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 100,
              height: 100,
              child: Center(
                child: _renderLocalPreview(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _renderLocalPreview() {
  return RtcLocalView.SurfaceView();
}

Widget _remoteVideo() {
  if (_remoteUid != null) {
    return RtcRemoteView.SurfaceView(uid: _remoteUid!);
  } else {
    return const Text(
      'Please wait for remote user to join',
      textAlign: TextAlign.center,
    );
  }
}
