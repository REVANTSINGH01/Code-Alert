import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/theme_provider.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                Navigator.pushNamed(context,'/home_page');
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
                Navigator.pushNamed(context, '/profilepage');
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
                  final prefs=await SharedPreferences.getInstance();
                   await prefs.remove("user_id");
                   if(!context.mounted)return;
                   Navigator.pushNamedAndRemoveUntil(
                     context,
                     '/login',
                       (route)=>false,
                   );
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
              "Welcome Back, Revant 👋",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "Upcoming Contests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView(
                children: [
                  contestCard(
                    textColor,
                    "Codeforces Round 1000",
                    "Starts in 3 hours",
                    "assets/svgs/code-forces.svg",
                    cardColor,
                  ),
                  contestCard(
                    textColor,
                    "LeetCode Weekly Contest",
                    "Tomorrow 8:00 PM",
                    "assets/svgs/leetcode.svg",
                    cardColor,
                  ),
                  contestCard(
                    textColor,
                    "CodeChef Starters",
                    "Friday 7:30 PM",
                    "assets/svgs/codechef.svg",
                    cardColor,
                  ),
                ],
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

  Widget contestCard(Color textColor,String title, String time, String iconPath, Color cardColor) {

    double iconSize = iconPath.contains("codechef") ? 40 : 22;

    return Card(
      color:cardColor,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: SvgPicture.asset(
          iconPath,
          width: iconSize,
          height: iconSize,
        ),
        title: Text(
            title,
            style: TextStyle(color: textColor),
        ),
        subtitle: Text(
            time,
            style: TextStyle(color: textColor),
        ),
        trailing:  Icon(
            Icons.notifications_active,
            color:textColor,
        ),
      ),
    );
  }
}