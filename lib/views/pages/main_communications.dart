import 'package:flutter/material.dart';
import 'package:nostr_relay_chat_application/logic/websocket_manager.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_relay_chat_application/widgets/messages.dart';

class MainCommunications extends StatefulWidget {
  const new({super.key});

  @override
  State<MainCommunications> createState() => _MainCommunicationsState();
}

class _MainCommunicationsState extends State<MainCommunications> {
  MaintainedWebSocket echoWebSocket = MaintainedWebSocket("wss://relay.primal.net");
  TextEditingController messageController = TextEditingController();
  final keys = Keys.generate();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: echoWebSocket.messages,
            ),
          ),
        ),
        Container(padding:EdgeInsets.fromLTRB(10, 0, 0, 0), child:
          TextField(cursorColor: Colors.white, style: TextStyle(color: Colors.white), controller: messageController, onEditingComplete: () {
            print('Public key: ${keys.public}');
            print('npub: ${keys.npub}');
            // Create and sign an event
            final event = Event.from(
              kind: 9,
              tags: [],
              content: messageController.text,
              secretKey: keys.secret,
            );
            echoWebSocket.sendMessage(event.serialize());
            setState(() {
              echoWebSocket.messages.add(MessageWidget(authorName: "#${keys.public.substring(0, 5)}", messageContent: " ${messageController.text}", colour: Colors.green));
            });
            messageController.clear();
          },)
        )
      ],
    );
  }
}