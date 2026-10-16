import 'package:flutter/material.dart';

class AddServerMenu extends StatelessWidget {
  new({super.key});

  final TextEditingController relayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 100,
        width: 100,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Column(
              children: [
                TextField(autofocus: true, controller: relayController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hint: Text("Relay URL"))),
                TextButton(onPressed: () {
                  
                }, child: Text("Add"))
              ],
            ),
          ),
      ),
    );
  }
}