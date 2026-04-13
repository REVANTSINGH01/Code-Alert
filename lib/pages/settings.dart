import 'package:flutter/material.dart';
class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {

    bool isEnabled=true;
    return Scaffold(
      appBar: AppBar(
        title: const Text("S E T T I N G S"),
      ),
      body:Padding(
        padding: const EdgeInsets.all(16),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Notifications" ,
                style: TextStyle(fontSize: 22),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile(
                title: Text("Enable Alerts"),
                subtitle: Text("Receive notifications for important updates"),
                value: isEnabled,
                onChanged: (val) {
                  setState(() => isEnabled = val);
                },
              ),
            )
          ],
        )
      )
    );
  }

  void setState(bool Function() param0) {}
}