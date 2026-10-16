import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nostr_relay_chat_application/logic/notifier.dart';
import 'package:nostr_relay_chat_application/logic/websocket_manager.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_relay_chat_application/widgets/messages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class MainCommunications extends StatefulWidget {
  const new({super.key});

  @override
  State<MainCommunications> createState() => _MainCommunicationsState();
}

class _MainCommunicationsState extends State<MainCommunications> {
  TextEditingController messageController = TextEditingController();
  final keys = Keys.generate();
  bool isTyping = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: messagesNotifier, builder: (context, child) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    children: messagesNotifier.messages.values.toList()
                  ),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 10), // strange way to add padding but hear me out.
                Expanded(
                  child: TextField(
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(hint: Text("Message..")),
                    controller: messageController,
                    onEditingComplete: () {
                      _sendMessage(keys, messageController);
                      setState(() {
                        isTyping = false;
                      });
                    },
                    onChanged: (value) {
                      if (!isTyping) {
                        setState(() {
                          isTyping = true;
                        });
                      } else if (messageController.text == "") {
                        setState(() {
                          isTyping = false;
                        });
                      }
                    },
                  )
                ),
                Visibility(
                  visible: !isTyping,
                  child: Row(
                    children: [
                      IconButton(onPressed: _selectCamera, icon: Icon(Icons.camera_alt)),
                      IconButton(onPressed: _selectImage, icon: Icon(Icons.image)),
                    ],
                  ),
                ),
                IconButton(onPressed: () {
                  _sendMessage(keys, messageController);
                  setState(() {
                    isTyping = false;
                  });
                }, icon: Icon(Icons.send))
              ]
            )
          ],
        ),
      );
  });
  }
}

void _selectImage () async {
  final picker = ImagePicker();
  // Pick an image.
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) _sendImage(image);
}

void _selectCamera () async {
  final picker = ImagePicker();
  // Capture a photo.
  final XFile? image = await picker.pickImage(source: ImageSource.camera);
  if (image != null) _sendImage(image);
}

void _sendImage (XFile image) async {
  var url = Uri.https("blossom.moviethingy.xyz", "/upload");
  Uint8List byteImage = await image.readAsBytes();
  String imageHash = hex.encode(sha256(byteImage));
  final keys = Keys.generate();
  final event = Event.from(
    kind: 24242,
    tags: [["t", "upload"], ["x", imageHash], ["expiration", (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 600).toString()]], // this tilda rounds, crazy work..
    content: "",
    secretKey: keys.secret,
  );
  String serializedEvent = event.serialize();
  serializedEvent = serializedEvent.substring(9, serializedEvent.length - 1);
  print("uwu ${image.mimeType}");
  print("Nostr ${base64Url.encode(utf8.encode(serializedEvent))}");
  var response = await http.put(url, headers: {"Authorization": "Nostr ${base64Url.encode(utf8.encode(serializedEvent))}", "Content-Type": image.mimeType ?? "image/jpg", "X-Content-Length": byteImage.length.toString(), "X-SHA-256": imageHash}, body: byteImage);
  print("RESPONSE: ${response.statusCode}");
  print("RESPONSE: ${response.body}");
  final dataJson = jsonDecode(response.body.toString());
  final imageEvent = Event.from(
    kind: 20,
    tags: [["title", "Image"], ["imeta", "url ${dataJson["url"]}"], ["t", "zolo-chat"], ["x", imageHash]],
    content: "An image sent by a Zolo user.",
    secretKey: keys.secret,
  );
  messagesNotifier.send(imageEvent, keys, true);
}

void _sendMessage (Keys keys, TextEditingController messageController) {
  final event = Event.from(
    kind: 9,
    tags: [["t", "zolo-chat"]],
    content: messageController.text,
    secretKey: keys.secret,
  );
  
  messagesNotifier.send(event, keys, false);
  messageController.clear();
}