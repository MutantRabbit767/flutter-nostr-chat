import 'package:flutter/material.dart';
import 'package:nostr_relay_chat_application/logic/notifier.dart';
import 'package:nostr_relay_chat_application/logic/websocket_manager.dart';
import 'package:nostr_relay_chat_application/widgets/add_server_menu.dart';
import 'package:nostr_relay_chat_application/widgets/server_widget.dart';

class Servers extends StatefulWidget {
  const new({super.key});

  @override
  State<Servers> createState() => _ServersState();
}

class _ServersState extends State<Servers> {
  void _showOverlay (BuildContext context) {
    OverlayState overlayState = Overlay.of(context);

    OverlayEntry addServerPopup = OverlayEntry(builder: (context) {
      return AddServerMenu();
    });

    overlayState.insert(addServerPopup);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text("+", style: TextStyle(fontSize: 30)),
        onPressed: () {
          // _showOverlay(context);
        },
      ),
      body: ListenableBuilder(listenable: webSocketNotifier, builder: (context, child) {
        return Column(
          children: webSocketNotifier.serverWidgets.values.toList(),
        );
      }),
    );
  }
}