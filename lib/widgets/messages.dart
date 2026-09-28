import 'package:flutter/material.dart';

class MessageWidget extends StatefulWidget {
  const new({super.key, required this.authorName, required this.messageContent, required this.colour});

  final String authorName;
  final String messageContent;
  final Color colour;

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(widget.authorName, style: TextStyle(color: widget.colour, fontSize: 20)),
        SizedBox(width: 325, child: Text(widget.messageContent, style: TextStyle(color: Colors.white, fontSize:  20)))
      ]
    );
  }
}