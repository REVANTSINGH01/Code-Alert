import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/theme_provider.dart';
import '../services/api_service.dart';
import 'dart:async';
import '../pages/custom_calendar.dart';
import '../pages/overlay_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() =>
      _HomePageState();
}
  class _HomePageState extends State<HomePage>{

    final List<DateTime> myContestDates = [
      DateTime.now(),
      DateTime.now().add(const Duration(days: 2)),
      DateTime.now().add(const Duration(days: 5)),
    ];
    // 🔴 ADD THIS: Tracks the currently selected date on the calendar
    DateTime selectedDate = DateTime.now();
    Timer? timer;
    Timer? dataSyncTimer;
    String username="";
    List contests = [];
    bool contestsLoading = true;
    @override
    void initState() {
      super.initState();
      initialize();
      timer =
          Timer.periodic(
            const Duration(seconds:1), (_){
              if(mounted){
                setState(() {});
              }
            },
          );
    }
    Future<void> initialize() async {
      await loadUserData();
      await loadContests();
      Future.microtask(() async {
        try{
          await ApiService.syncDashboard();
        }
        catch(e){
          print(e);
        }
      });


    }
    Future<void> loadUserData()
    async {
      final prefs =await SharedPreferences.getInstance();
      if(!mounted)return;
      setState((){
        username = prefs.getString("username") ?? "User";
      });
    }

    Future<void> loadContests()
    async {
      if(mounted){
        setState(() {
          contestsLoading=true;
        });
      }
      try{
        final data =
        await ApiService
            .getContests()
            .timeout(
          const Duration(
              seconds: 8
          ),
        );
        if(!mounted)return;
        print(data);
        setState(() {
          contests = data;
        });
      }
      catch(e){
        print(e);

      }
      finally{
        setState(() {

          contestsLoading =
          false;

        });
      }
    }

    Future<void> logout(BuildContext context)async{
      final prefs=await SharedPreferences.getInstance();
      await prefs.clear();
      if(!mounted)return ;
      Navigator.pushNamedAndRemoveUntil(context, '/login',(route)=>false,);
    }
    @override
    Widget build(BuildContext context) {
      final theme=context.watch<ThemeProvider>();
      Color textColor= theme.bgColor==const Color(0xFF121212)?Colors.white:Colors.black;
      Color cardColor=theme.bgColor==const Color(0xFF121212)?const Color(0xFF1E1E1E):Colors.white;
      return Scaffold(
        backgroundColor: theme.bgColor,
        appBar: AppBar(
          backgroundColor: theme.bgColor,
          title: Text("CodeAlert",
            style: TextStyle(color: textColor),),
          iconTheme: IconThemeData(
            color:textColor,
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 30, color: Colors.blue),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "CodeAlert",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              ListTile(
                leading: const Icon(Icons.home),
                title:  Text("H O M E"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context,'/home_page');
                },
              ),
              ListTile(
                leading: const Icon(Icons.remember_me),
                title:  Text("R E M I N D E R"),
                onTap:(){
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/reminders');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title:  Text("P R O F I L E"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context,'/profilepage');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title:  Text("A B O U T   A P P"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/about_app');
                },
              ),

              ListTile(
                leading: const Icon(Icons.settings),
                title: Text("S E T T I N G S"),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');

                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async{
                    logout(context);
                  },
                  icon: const Icon(Icons.logout),
                  label:  Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ),
            ],
          ),
        ),

        // bottomNavigationBar: BottomNavigationBar(
        //   backgroundColor: theme.bgColor,
        //   unselectedItemColor: Colors.white,
        //   currentIndex: 0,
        //   onTap: (index) {
        //
        //     if(index == 0){
        //       Navigator.pushNamed(context, '/home_page');
        //     }
        //
        //     if(index == 1){
        //       Navigator.pushNamed(context, '/');
        //     }
        //
        //     if(index == 2){
        //       Navigator.pushNamed(context, '/settings');
        //     }
        //
        //   },
        //   items: const[
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.home),
        //         label: "Home",
        //
        //       ),
        //       BottomNavigationBarItem(
        //       icon: Icon(Icons.alarm),
        //       label: "Alert",
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.settings),
        //       label: "Settings",
        //     )
        //
        //   ],
        // ),
        body:DefaultTextStyle(
          style: TextStyle(color: textColor),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Welcome Back, $username👋",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Upcoming Contests",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.55,
                    // Takes up 70% of the screen width
                    child: MonthlyCalendar(
                      cardColor: cardColor,
                      textColor: textColor,
                      accentColor: const Color(0xFF00E5FF),
                      contestDates: myContestDates, // Or whatever your variable is
                      onDateSelected: (date) {
                        print("Selected: $date");
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const SizedBox(height: 15),
                Expanded(

                  child:

                  contestsLoading

                      ?

                  const Center(

                    child:
                    CircularProgressIndicator(),

                  )

                      :

                  ListView.builder(

                    itemCount:
                    contests.length,

                    itemBuilder:
                        (
                        context,
                        index
                        ){

                      final contest =
                      contests[index];
                      return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            showContestDetails(context, contest, textColor);
                            },
                          child: contestCard(
                            textColor,
                            contest["name"],
                            contest["start_time"],
                            getIcon(contest["platform"]),
                            cardColor,
                          ),
                      );
                    },

                  ),

                ),

                const SizedBox(height: 10),

                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pushNamed(context, '/reminders');
                //   },
                //   child:  Text("Set Reminder"),
                // ),
              ],
            ),
          ),
        ),
      )
      ;
    }
    @override
    void dispose(){

      timer?.cancel();

      super.dispose();

    }

    Widget contestCard(

        Color textColor,

        String title,

        String time,

        String iconPath,

        Color cardColor

        ){

      double iconSize =

      iconPath.contains(
          "codechef"
      )

          ?

      40

          :

      22;

      DateTime start =

      DateTime.parse(
          time
      );

      Duration diff =

      start.difference(
          DateTime.now()
      );

      String countdown;

      if(
      diff.isNegative
      ){

        countdown =
        "Started";

      }

      else{

        int days =
            diff.inDays;

        int hours =
            diff.inHours % 24;

        int minutes =
            diff.inMinutes % 60;

        int seconds =
            diff.inSeconds % 60;

        countdown =

        "${days}d : "

            "${hours.toString().padLeft(2,'0')}h : "

            "${minutes.toString().padLeft(2,'0')}m : "

            "${seconds.toString().padLeft(2,'0')}s";

      }

      return Card(

        color:
        cardColor,

        margin:

        const EdgeInsets.only(
            bottom:10
        ),

        child:

        ListTile(

          leading:

          SvgPicture.asset(

            iconPath,

            width:
            iconSize,

            height:
            iconSize,

          ),

          title:

          Text(

            title,

            style:

            TextStyle(
              color:
              textColor,
            ),

          ),

          subtitle:

          Text(

            countdown,

            style:

            TextStyle(
              color:
              textColor,
            ),

          ),



        ),

      );

    }
    String getIcon(String platform){

      switch(platform){

        case "Codeforces":
          return
            "assets/svgs/code-forces.svg";

        case "LeetCode":
          return
            "assets/svgs/leetcode.svg";

        case "CodeChef":
          return
            "assets/svgs/codechef.svg";

        default:
          return
            "assets/svgs/code-forces.svg";

      }

    }

}