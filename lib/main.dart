import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_relay_chat_application/logic/notifier.dart';
import 'package:nostr_relay_chat_application/logic/websocket_manager.dart';
import 'package:nostr_relay_chat_application/views/pages/main_communications.dart';
import 'package:nostr_relay_chat_application/views/pages/private_communications.dart';
import 'package:nostr_relay_chat_application/views/pages/servers.dart';
import 'package:flutter_background/flutter_background.dart';

int page = 0;
String appBarTitle = "Main Communications.";
bool? notificationsReady = false;
bool isInBackground = false;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ByteData data = await PlatformAssetBundle().load('assets/ca/int-ye1.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(const MainApp());
  List<String> websocketURLs = ["wss://relay.primal.net", "wss://nos.lol", "wss://relay.moviethingy.xyz"];


  for (var url in websocketURLs) {
    webSocketNotifier.push(MaintainedWebSocket(url));
  }
  
  if(Platform.isAndroid) {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Network Manager.",
      notificationText: "Keeping you connected for notifications.",
      notificationImportance: AndroidNotificationImportance.high,
      enableWifiLock: true,
    );

    FlutterBackground.initialize(androidConfig: androidConfig);
  } else if (Platform.isLinux) {
    isInBackground = true; // hacky fix to make notifications always happen on Linux until I can implement a way to track whether or not the window is active on Linux.
  }

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
  final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
    defaultActionName: 'Open notification');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    linux: initializationSettingsLinux
  );

  notificationsReady = await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver{
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    isInBackground = state == AppLifecycleState.paused;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark
        )
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle)
        ),
        drawer: SafeArea(
          child: Builder(
            builder: (context) {
              return Drawer(
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Main Communications"),
                      leading: Icon(Icons.message),
                      onTap: () {
                        setState(() {
                          page = 0;
                          appBarTitle = "Main Communications.";
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text("Private Communications"),
                      leading: Icon(Icons.privacy_tip),
                      onTap: () {
                        setState(() {
                          page = 1;
                          appBarTitle = "Private Communications.";
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text("Servers"),
                      leading: Icon(Icons.storage),
                      onTap: () {
                        setState(() {
                          page = 2;
                          appBarTitle = "Servers.";
                        });
                        Navigator.pop(context);
                      },
                    )
                  ]
                )
              );
            },
          ),
        ),
        body: PageManager()
      )
    );
  }
}

List<Widget> pages = [
  MainCommunications(),
  PrivateCommunications(),
  Servers()
];

class PageManager extends StatefulWidget {
  const new({super.key});

  @override
  State<PageManager> createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  @override
  Widget build(BuildContext context) {
    return pages.elementAt(page);
  }
}