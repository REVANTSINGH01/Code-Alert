import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/theme_provider.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {

  String username = "User";

  double? lcRating;

  int? cfRating;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  Future<void> loadUser() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final dashboard =
      await ApiService.syncDashboard();

      if (!mounted) return;

      setState(() {

        username =
            prefs.getString(
                "username"
            ) ??
                "User";

        if (
        dashboard["leetcode"]
            !=
            null
        ) {
          lcRating =
              (
                  dashboard[
                  "leetcode"
                  ]["rating"]
                  as num
              )
                  .toDouble();
        }

        if (
        dashboard["codeforces"]
            !=
            null
        ) {
          cfRating =
              (
                  dashboard[
                  "codeforces"
                  ]["rating"]
                  as num
              )
                  .toInt();
        }

        loading = false;

      });

    }

    catch (e) {

      print(e);

      if (!mounted)
        return;

      setState(() {

        loading = false;

      });

    }

  }

  Widget profileCard({

    required IconData icon,

    required String title,

    required String value,

    required Color textColor,

    required Color cardColor,

  }) {

    return Card(

      color: cardColor,

      child: ListTile(

        leading: Icon(
          icon,
          color: textColor,
        ),

        title: Text(
          title,
          style: TextStyle(
            color: textColor,
          ),
        ),

        trailing: Text(
          value,
          style: TextStyle(
            color: textColor,
          ),
        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    final theme =
    context.watch<ThemeProvider>();

    Color textColor =
    theme.bgColor ==
        const Color(
            0xFF121212
        )
        ?
    Colors.white
        :
    Colors.black;

    Color cardColor =
    theme.bgColor ==
        const Color(
            0xFF121212
        )
        ?
    const Color(
        0xFF1E1E1E
    )
        :
    Colors.white;

    return Scaffold(

      backgroundColor:
      theme.bgColor,

      appBar:

      AppBar(

        backgroundColor:
        theme.bgColor,

        title:

        Text(

          "Profile",

          style:

          TextStyle(
            color:
            textColor,
          ),

        ),

      ),

      body:

      loading

          ?

      const Center(

        child:
        CircularProgressIndicator(),

      )

          :

      Padding(

        padding:
        const EdgeInsets.all(
            20
        ),

        child:

        Column(

          children: [

            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            const SizedBox(
                height: 15
            ),

            Text(

              username,

              style:

              TextStyle(

                color:
                textColor,

                fontSize:
                24,

                fontWeight:
                FontWeight.bold,

              ),

            ),

            const SizedBox(
                height: 20
            ),

            profileCard(

              icon:
              Icons.code,

              title:
              "LeetCode Rating",

              value:
              lcRating
                  ?.toStringAsFixed(2)
                  ??
                  "--",

              textColor:
              textColor,

              cardColor:
              cardColor,

            ),

            profileCard(

              icon:
              Icons.star,

              title:
              "Codeforces Rating",

              value:
              cfRating
                  ?.toString()
                  ??
                  "--",

              textColor:
              textColor,

              cardColor:
              cardColor,

            ),

            const SizedBox(
                height: 20
            ),

            ElevatedButton(

              onPressed:
              loadUser,

              child:
              const Text(
                  "Refresh"
              ),

            )

          ],

        ),

      ),

    );

  }

}