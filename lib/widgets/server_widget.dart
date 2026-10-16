import 'package:flutter/material.dart';

class ServerWidget extends StatefulWidget {
  new({super.key, this.serverConnected = false, required this.serverURL});

  bool serverConnected;
  final String serverURL;

  @override
  State<ServerWidget> createState() => _ServerWidgetState();
}

class _ServerWidgetState extends State<ServerWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 5, 0),
      child: Row(
        spacing: 8,
        children: [
          Icon(Icons.circle, color: widget.serverConnected ? Colors.green : Colors.red),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.serverURL, style: TextStyle(fontSize: 20)),
                  Icon(Icons.remove)
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}