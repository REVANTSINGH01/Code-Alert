import 'package:flutter/material.dart';
class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {

    bool isEnabled=true;
    bool enabled=true;
    String selectSound = "Default";
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                      SwitchListTile(
                        title: Text("Enable Alerts"),
                        subtitle: Text("Receive notifications for important updates"),
                        value: isEnabled,
                        onChanged: (val) {
                          setAlert(() => isEnabled = val);
                        },
                      ),
                    Divider(),
                    SwitchListTile(
                      title: Text("Vibration"),
                      subtitle: Text("Vibrate device when alert arrives"),
                      value: enabled, onChanged: (val){ setVibrate(()=>enabled=val);}
                    ),
                    Divider(),
                    ListTile(title:Text("Notification Sound"),subtitle:Text("Choose notification sound"),
                        trailing:DropdownButton<String>(value:selectSound,underline: SizedBox(),
                        items:["Default","Beep"].map((e)=>DropdownMenuItem(value :e,child:Text(e)))
.toList(),onChanged: (val)=>setSound(()=>selectSound=val!),
                        ),
                    ),
                  ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setAlert(bool Function() param0) {}

  void setVibrate(bool Function() param0){}

  void setSound(String Function() param0) {}
}