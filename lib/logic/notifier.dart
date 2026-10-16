import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_relay_chat_application/logic/websocket_manager.dart';
import 'package:nostr_relay_chat_application/main.dart';
import 'package:nostr_relay_chat_application/widgets/messages.dart';
import 'package:nostr_relay_chat_application/widgets/server_widget.dart';

MessagesNotifier messagesNotifier = MessagesNotifier();
WebSocketNotifiers webSocketNotifier = WebSocketNotifiers();

class MessagesNotifier extends ChangeNotifier {
  final Map<String, MessageWidget> _messages = {};
  Map<String, MessageWidget> get messages => _messages; // this seems extremely redundant to me, but they did this in the Google documentation soo.

  final Map<String, String> _unsentMessages = {};
  Map<String, String> get unsentMessages => _unsentMessages;

  void push (String eventID, MessageWidget newMessage, bool notify) {
    if (_messages.containsKey(eventID)) return;
    _messages.addEntries([MapEntry(eventID, newMessage)]);
    
    notifyListeners();

    if (!notify) return;

    if (notificationsReady == true && isInBackground) {
      const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('sussy', 'Zolo',
        channelDescription: 'Somebody sent a message!',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
            
      const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
          
      flutterLocalNotificationsPlugin.show(
        id: 0, title: "<@${newMessage.authorName}>", body: newMessage.messageContent, notificationDetails: notificationDetails);
    }
  }

  void send (Event event, Keys keys, bool isImage, String? url) {
    if (!isImage) {
      push(event.id, MessageWidget(authorName: keys.public.substring(0, 5), messageContent: event.content, colour: Colors.green), false);
    } else {
      push(event.id, MessageWidget(authorName: keys.public.substring(0, 5), messageContent: event.content, colour: Colors.green, isImage: true, url: url), true);
    }
    String eventSerialized = event.serialize();
    _unsentMessages.addEntries([MapEntry(event.id, eventSerialized)]);
    for (var websocket in webSocketNotifier.websockets.values) {
      websocket.sendMessage(eventSerialized);
    }
  }

  void sent (String eventID) {
    _messages.update(eventID, (previous) {
      if(messagesNotifier.messages[eventID]!.isImage) {
        return MessageWidget(authorName: previous.authorName, messageContent: previous.messageContent, colour: previous.colour, sent: true, isImage: true, url: messagesNotifier.messages[eventID]?.url);
      } else {
        return MessageWidget(authorName: previous.authorName, messageContent: previous.messageContent, colour: previous.colour, sent: true);
      }
    });
    _unsentMessages.remove(eventID);
    notifyListeners();
  }
}

class WebSocketNotifiers extends ChangeNotifier {
  final Map<String, MaintainedWebSocket> _websockets = {};
  Map<String, MaintainedWebSocket> get websockets => _websockets;

  final Map<String, ServerWidget> _serverWidgets = {};
  Map<String, ServerWidget> get serverWidgets => _serverWidgets;

  void push (MaintainedWebSocket newWebSocket) {
    _websockets.addEntries([MapEntry(newWebSocket.url, newWebSocket)]);
    _serverWidgets.addEntries([MapEntry(newWebSocket.url, ServerWidget(serverURL: newWebSocket.url))]);
    notifyListeners();
  }

  void changeStatus (String url, bool status) {
    _serverWidgets.update(url, (value) {
      return ServerWidget(serverURL: url, serverConnected: status);
    });
    notifyListeners();
  }
}