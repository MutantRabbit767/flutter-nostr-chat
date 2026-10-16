import 'dart:convert';
import 'package:nostr/nostr.dart';
import 'package:nostr_relay_chat_application/main.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:nostr_relay_chat_application/logic/notifier.dart';
import 'package:nostr_relay_chat_application/widgets/messages.dart';


class MaintainedWebSocket {
  WebSocketChannel ?websocket;
  String url = "";
  static const Map<String, List<String>> tagFilter = {"t": [ "zolo-chat" ]};

  MaintainedWebSocket (String url) {
    this.url = url;

    final wsUrl = Uri.parse(url);
    final channel = WebSocketChannel.connect(wsUrl);

    channel.ready.then((nothing) {
      webSocketNotifier.changeStatus(url, true);
      websocket = channel;

      for (var message in messagesNotifier.unsentMessages.values) {
        channel.sink.add(message);
      }

      final request = Request(
          subscriptionId: generateRandomHex(),
          filters: [const Filter(kinds: [9, 20], limit: 10, tagFilters: tagFilter)],
      );
      channel.sink.add(request.serialize());

      channel.stream.listen((message) {
        final dataJson = jsonDecode(message.toString());
        if (dataJson[0] == "EVENT") {
          print("KIND: ${dataJson[2]["kind"]}");
          if (dataJson[2]["kind"] == 9) {
            messagesNotifier.push(dataJson[2]["id"], MessageWidget(authorName: dataJson[2]["pubkey"].substring(0, 5), messageContent: dataJson[2]["content"], colour: Colors.yellow, sent: true,), true);
          } else if (dataJson[2]["kind"] == 20) {
            print (dataJson);
            print(dataJson[2]["tags"][1][1].substring(4));
            messagesNotifier.push(dataJson[2]["id"], MessageWidget(authorName: dataJson[2]["pubkey"].substring(0, 5), messageContent: dataJson[2]["content"], colour: Colors.yellow, sent: true, isImage: true, url: dataJson[2]["tags"][1][1].substring(4)), true);
          }
        } else if (dataJson[0] == "OK") {
          messagesNotifier.sent(dataJson[1]);
        }
      });

      channel.sink.done.then((value) {
        print("done");
        reconnect();
      });

    }).catchError((error) {
      print(error.toString());
      reconnect();
    });
  }

  void reconnect() async {
    await Future.delayed(const Duration(seconds : 5));
    webSocketNotifier.changeStatus(url, false);
    websocket?.sink.close(status.abnormalClosure);
    websocket = null;
    webSocketNotifier.websockets.update(url, (nahhIdontNeedAllat) {
      return MaintainedWebSocket(url);
    });
  }

  void sendMessage (String message) {
    websocket?.sink.add(message);
  }
}
