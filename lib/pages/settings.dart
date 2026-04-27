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
    Color textColor= theme.bgColor==const Color(0xFF121212)?Colors.white:Colors.black;
    Color cardColor=theme.bgColor==const Color(0xFF121212)?const Color(0xFF1E1E1E):Colors.white;
    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        backgroundColor: theme.bgColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text("S E T T I N G S",style: TextStyle(color: textColor),),
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
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                      SwitchListTile(
                        title: Text("Enable Alerts",style:TextStyle(color:textColor)),
                        subtitle: Text("Receive notifications for important updates",style:TextStyle(color:textColor)),
                        value: isEnabled,
                        onChanged: (val) {
                          setAlert(() => isEnabled = val);
                        },
                      ),
                    Divider(),
                    SwitchListTile(
                      title: Text("Vibration",style:TextStyle(color:textColor)),
                      subtitle: Text("Vibrate device when alert arrives",style:TextStyle(color:textColor)),
                      value: enabled, onChanged: (val){ setVibrate(()=>enabled=val);}
                    ),
                    Divider(),
                    ListTile(title:Text("Notification Sound",style:TextStyle(color:textColor)),
                      subtitle:Text("Choose notification sound",style:TextStyle(color:textColor)),
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
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              child: DefaultTextStyle(style: TextStyle(color: textColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                        title:Text("Enable Quiet Mode",
                            style:TextStyle(color: textColor),
                        ),
                        subtitle: Text("QuietEnabledts during selected Time",style: TextStyle(color: textColor),),
                        value: quietEnabled,
                        onChanged: (val)=>{}
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Start Time",style:TextStyle(color:textColor)),
                      subtitle: Text("Select quiet hours time start",style: TextStyle(color: textColor),),
                      trailing: Text(
                        startTime.format(context),style: TextStyle(fontSize: 20),
                      ),
                      onTap: pickStartTime,
                    ),
                    Divider(),
                    ListTile(
                      title: Text("End Time",style:TextStyle(color:textColor)),
                      subtitle: Text("Select quiet hours time end",style:TextStyle(color:textColor)),
                      trailing: Text(
                        endTime.format(context),style: TextStyle(fontSize: 20),
                      ),
                      onTap: pickEndTime,
                    )
                  ],
                ),
              ),
            ),
            Text("Appearance",style:TextStyle(fontSize: 22)),
            Card(

              color: cardColor,
              shape:RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              child: DefaultTextStyle(style: TextStyle(color: textColor),
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Themes",
                        style: TextStyle(fontSize: 19,color: textColor),
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
                            title: Text("Light",style:TextStyle(color:textColor)),

                          ),
                          RadioListTile(
                            value: ThemeOption.dark,
                            title: Text("Dark",style:TextStyle(color:textColor)),
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
                    ListTile(title:Text("Font Size"),subtitle:Text("Select App's font size",style:TextStyle(color:textColor)),
                      trailing:DropdownButton<String>(value:selectFontSize,underline: SizedBox(),
                        items:["Default","Small","Medium","Large"].map((e)=>DropdownMenuItem(value :e,child:Text(e)))
                            .toList(),onChanged: (val)=>setFontSize(()=>selectFontSize=val!),
                      ),
                    ),
                  ],
                ),
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