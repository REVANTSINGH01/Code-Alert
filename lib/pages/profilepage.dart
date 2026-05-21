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

class _ProfilePage
    extends State<ProfilePage> {

  String username = "User";

  double? lcRating;

  int? cfRating;

  int reminders = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadUserData();
  }

  Future<void> loadUserData()
  async {

    try {

      final prefs =
      await SharedPreferences
          .getInstance();

      username =
          prefs.getString(
              "username") ??
              "User";
  }

  @override
  Widget build(
      BuildContext context) {

    final theme =
    context.watch<
        ThemeProvider>();

    Color textColor =
    theme.bgColor ==
        const Color(
            0xFF121212)
        ? Colors.white
        : Colors.black;

    Color cardColor =
    theme.bgColor ==
        const Color(
            0xFF121212)
        ? const Color(
        0xFF1E1E1E)
        : Colors.white;

    return Scaffold(

      backgroundColor:
      theme.bgColor,

      appBar: AppBar(

        backgroundColor:
        theme.bgColor,

        iconTheme:
        IconThemeData(
            color:
            textColor),

        title: Text(

          "Profile",

          style: TextStyle(
              color:
              textColor),
        ),
      ),

      body:
      loading

          ? const Center(

        child:
        CircularProgressIndicator(),
      )

          : Padding(

        padding:
        const EdgeInsets
            .all(
            16),

        child:
        Column(

          children: [

            const CircleAvatar(

              radius:
              50,

              child:
              Icon(
                Icons
                    .person,

                size:
                50,
              ),
            ),

            const SizedBox(
                height:
                10),

            Text(

              username,

              style:
              TextStyle(

                color:
                textColor,

                fontSize:
                22,

                fontWeight:
                FontWeight
                    .bold,
              ),
            ),

            Text(

              "Competitive Programmer",

              style:
              TextStyle(
                color:
                textColor,
              ),
            ),

            const SizedBox(
                height:
                20),

            Card(

              color:
              cardColor,

              child:
              ListTile(

                leading:
                Icon(

                  Icons
                      .code,

                  color:
                  textColor,
                ),

                title:
                Text(

                  "LeetCode Rating",

                  style:
                  TextStyle(
                    color:
                    textColor,
                  ),
                ),

                trailing:
                Text(

                  lcRating
                      ?.toString() ??
                      "--",

                  style:
                  TextStyle(
                    color:
                    textColor,
                  ),
                ),
              ),
            ),

            Card(

              color:
              cardColor,

              child:
              ListTile(

                leading:
                Icon(

                  Icons
                      .star,

                  color:
                  textColor,
                ),

                title:
                Text(

                  "Codeforces Rating",

                  style:
                  TextStyle(
                    color:
                    textColor,
                  ),
                ),

                trailing:
                Text(

                  cfRating
                      ?.toString() ??
                      "--",

                  style:
                  TextStyle(
                    color:
                    textColor,
                  ),
                ),
              ),
            ),

            Card(

              color:
              cardColor,

              child:
              ListTile(

                leading:
                Icon(

                  Icons
                      .notifications,

                  color:
                  textColor,
                ),

                title:
                Text(

                  "Active Reminders",

                  style:
                  TextStyle(
                    color:
                    textColor,
                  ),
                ),

                trailing:
                Text(

                  reminders
                      .toString(),

                  style:
                  TextStyle(
                    color:
                    textColor,
                  ),
                ),
              ),
            ),

            const SizedBox(
                height:
                20),

            ElevatedButton(

              style:
              ElevatedButton
                  .styleFrom(

                backgroundColor:
                cardColor,
              ),

              onPressed:
                  () {},

              child:
              Text(

                "Edit Profile",

                style:
                TextStyle(
                  color:
                  textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}