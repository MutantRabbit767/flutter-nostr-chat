import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_relay_chat_application/widgets/messages.dart';

class MaintainedWebSocket {
    WebSocket ?websocket;
    List<MessageWidget> messages = [ MessageWidget(authorName: "cohen", messageContent: " somethihfn very long that would need to wrap", colour: Colors.red) ];

    MaintainedWebSocket (String url) {
        Future<WebSocket> websocketFuture = WebSocket.connect(url);
        websocketFuture.then((socket) {
            websocket = socket;
            final request = Request(
                subscriptionId: generateRandomHex(),
                filters: [const Filter(kinds: [9], limit: 10)],
            );
            websocket?.add(request.serialize());
            print("sent");
            websocket?.listen((data) {
                print(data);
                final dataJson = jsonDecode(data.toString());
                if (dataJson[0] == "EVENT") {
                    messages.add(MessageWidget(authorName: dataJson[2]["pubkey"].substring(0, 5), messageContent: dataJson[2]["content"], colour: Colors.yellow));
                }
            });
        }).catchError((onError) {
            print(onError.toString());
        });
    }

    sendMessage (String message) {
        websocket?.add(message);
    }
}
