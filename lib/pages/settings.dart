import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState()=> _SettingsState();
}

class _SettingsState extends State<Settings>{
  TimeOfDay startTime = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay endTime=TimeOfDay(hour: 7, minute: 0);
  bool isEnabled=true;
  bool enabled=true;
  String selectSound = "Default";
  String selectFontSize="Default";
  bool quietEnabled=false;
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    Color textColor= theme.bgColor==Colors.black?Colors.white:Colors.black;
    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        title: const Text("S E T T I N G S"),
      ),

      body:DefaultTextStyle(
        style: TextStyle(color: textColor),child:ListView(
        padding: const EdgeInsets.all(16),
        children:[
            Text(
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
            Text("Quiet Hours",style:TextStyle(fontSize:22)),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                      title:Text("Enable Quiet Mode"),
                      subtitle: Text("QuietEnabledts during selected Time"),
                      value: quietEnabled,
                      onChanged: (val)=>{}
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Start Time"),
                    subtitle: Text("Select quiet hours time start"),
                    trailing: Text(
                      startTime.format(context),style: TextStyle(fontSize: 20),
                    ),
                    onTap: pickStartTime,
                  ),
                  Divider(),
                  ListTile(
                    title: Text("End Time"),
                    subtitle: Text("Select quiet hours time end"),
                    trailing: Text(
                      endTime.format(context),style: TextStyle(fontSize: 20),
                    ),
                    onTap: pickEndTime,
                  )
                ],
              ),
            ),
            Text("Appearance",style:TextStyle(fontSize: 22)),
            Card(
              shape:RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Themes",
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  RadioGroup<ThemeOption>(
                    groupValue: theme.selectedTheme,
                    onChanged: (val) {
                      if(val!=null)context.read<ThemeProvider>().changeTheme(val);
                    },
                    child: Column(
                      children: [
                        RadioListTile(
                          value: ThemeOption.light,
                          title: Text("Light"),
                        ),
                        RadioListTile(
                          value: ThemeOption.dark,
                          title: Text("Dark"),
                        ),
                      ],
                    ),
                  ),

                  // RadioListTile<ThemeOption>(
                  //   title: Text("System Default"),
                  //   value: ThemeOption.system,
                  //   groupValue: selectedTheme,
                  //   onChanged: (val) {
                  //     setState(() {
                  //       selectedTheme = val!;
                  //     });
                  //   },
                  // ),
                  Divider(),
                  ListTile(title:Text("Font Size"),subtitle:Text("Select App's font size"),
                    trailing:DropdownButton<String>(value:selectFontSize,underline: SizedBox(),
                      items:["Default","Small","Medium","Large"].map((e)=>DropdownMenuItem(value :e,child:Text(e)))
                          .toList(),onChanged: (val)=>setFontSize(()=>selectFontSize=val!),
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
  Future<void> pickStartTime()async{
    TimeOfDay? picked=await showTimePicker(context: context, initialTime: startTime,);
    if(picked!=null){
      setState((){
        startTime=picked;
      });
    }
  }
  Future<void> pickEndTime()async {
    TimeOfDay? picked=await showTimePicker(context: context, initialTime: endTime,);
    if(picked!=null){
      setState(() {
        endTime=picked;
      });
    }
  }
  void setAlert(bool Function() param0) {}

  void setVibrate(bool Function() param0){}

  void setSound(String Function() param0) {}

  void setFontSize(String Function() param0) {}

}