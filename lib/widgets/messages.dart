import 'package:flutter/material.dart';

class MessageWidget extends StatefulWidget {
  const new({super.key, required this.authorName, required this.messageContent, required this.colour, this.sent = false, this.isImage = false, this.url});

  final String authorName;
  final String messageContent;
  final Color colour;
  final bool sent;

  final bool isImage;
  final String? url;

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, widget.isImage ? 10 : 0, 0, widget.isImage ? 10 : 3),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(widget.sent ? "<@${widget.authorName}>" : "<#${widget.authorName}>*", style: TextStyle(color: widget.colour, fontSize: 17)),
          Expanded(
            child: widget.isImage ? Padding(
              padding: EdgeInsets.fromLTRB(0, widget.isImage ? 5 : 0, 0, 0),
              child: Image.network(widget.url ?? ""),
            ) : Text(
              widget.messageContent,
              style: TextStyle(color: Colors.white, fontSize:  17)
            )
          )
        ]
      ),
    );
  }
}