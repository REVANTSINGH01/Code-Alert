import 'package:flutter/material.dart';

class Reminders extends StatelessWidget{
  const Reminders({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title : const Text("Set Reminders"),
        ),
      body:ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.alarm),
              title: Text("Solve DSA problems"),
              subtitle: Text("8:00 PM"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 10),
                  Icon(Icons.delete),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}