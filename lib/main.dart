import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nostr_relay_chat_application/logic/websocket_manager.dart';
import 'package:nostr_relay_chat_application/views/pages/main_communications.dart';
import 'package:nostr_relay_chat_application/views/pages/private_communications.dart';

int page = 0;
String appBarTitle = "Main Communications.";

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
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
                      title: Text("Main Communications."),
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
                      title: Text("Private Communications."),
                      leading: Icon(Icons.privacy_tip),
                      onTap: () {
                        setState(() {
                          page = 1;
                          appBarTitle = "Private Communications.";
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
  PrivateCommunications()
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