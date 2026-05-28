import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/theme_provider.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> with WidgetsBindingObserver{
  String username = "User";
  double? lcRating;
  int? cfRating;
  int? ccRating;
  int? lcSolved;
  int? cfSolved;
  int? ccSolved;
  String? cfRank;
  String? ccStars;
  bool loading = true;
  Timer? syncTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_){
      loadUser();
      },
    );

    syncTimer = Timer.periodic(
      const Duration(minutes: 2),
          (_) {
        if (mounted) {
          loadUser(showLoader: false);
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The moment the app comes back to the foreground, silently refresh!
      if (mounted) {
        loadUser(showLoader: false);
      }
    }
  }

  Future<void> loadUser({
    bool showLoader = true,
  }) async {

    try {

      if (showLoader && mounted) {
        setState(() {
          loading = true;
        });
      }

      final prefs =
      await SharedPreferences.getInstance();

      final dashboard =
      await ApiService.syncDashboard();

      if (!mounted) return;

      setState(() {

        username =
            prefs.getString("username")
                ??
                "User";

        lcRating =
        dashboard["leetcode"] != null
            ?
        double.tryParse(
          dashboard["leetcode"]["rating"]
              .toString(),
        )
            :
        null;

        cfRating =
        dashboard["codeforces"] != null
            ?
        int.tryParse(
          dashboard["codeforces"]["rating"]
              .toString(),
        )
            :
        null;
        ccRating =dashboard["codechef"]!=null ?int.tryParse(dashboard["codechef"]["rating"]
            .toString(),):null;
        lcSolved = dashboard["leetcode"]?["problems_solved"];
        cfSolved = dashboard["codeforces"]?["problems_solved"];
        ccSolved = dashboard["codechef"]?["problems_solved"];
        cfRank=dashboard["codeforces"]?["rank"];
        ccStars=dashboard["codechef"]?["stars"];
        loading = false;

      });

    } catch (e) {

      print(e);
      if(e.toString().contains("Session_Expired",)){
        syncTimer?.cancel();
        final prefs=await SharedPreferences.getInstance();
        await prefs.clear();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route)=>false,);
        return;
      }

      if(mounted){
        setState(() {
          loading = false;
        });
      }

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

      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

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
            fontWeight:
            FontWeight.bold,
          ),
        ),

      ),

    );

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    syncTimer?.cancel();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    final theme =
    context.watch<ThemeProvider>();

    Color textColor =
    theme.bgColor ==
        const Color(0xFF121212)
        ?
    Colors.white
        :
    Colors.black;

    Color cardColor =
    theme.bgColor ==
        const Color(0xFF121212)
        ?
    const Color(0xFF1E1E1E)
        :
    Colors.white;

    return Scaffold(

      backgroundColor: theme.bgColor,

      appBar: AppBar(

        backgroundColor: theme.bgColor,

        title: Text(
          "Profile",
          style: TextStyle(
            color: textColor,
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

      RefreshIndicator(

        onRefresh: () async {
          await loadUser();
        },

        child: SingleChildScrollView(

          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.all(20),

          child: Column(

            children: [

              const CircleAvatar(
                radius: 50,
                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Text(

                username,

                style: TextStyle(

                  color: textColor,

                  fontSize: 24,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),

              const SizedBox(
                height: 24,
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
                icon: Icons.task_alt,
                title: "LeetCode Questions",
                value:
                lcSolved
                    ?.toString()
                    ??
                    "--",
                textColor: textColor,
                cardColor: cardColor,
              ),
              profileCard(

                icon:
                Icons.task_alt,
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
              profileCard(
                icon: Icons.emoji_events,
                title: "Codeforces Questions",
                value:
                cfSolved
                    ?.toString()
                    ??
                    "--",
                textColor: textColor,
                cardColor: cardColor,
              ),
              const SizedBox(
                height: 24,
              ),

              profileCard(

                icon:
                Icons.code,

                title:
                "Codechef Rating",

                value:
                ccRating
                    ?.toStringAsFixed(2)
                    ??
                    "--",

                textColor:
                textColor,

                cardColor:
                cardColor,

              ),
              profileCard(icon: Icons.stars,
                  title: "Codeforces Title",
                  value: cfRank?.toString() ?? "--",
                  textColor: textColor,
                  cardColor: cardColor

              ),
              profileCard(
                icon: Icons.task_alt,
                title: "CodeChef Questions",
                value:
                ccSolved
                    ?.toString()
                    ??
                    "--",
                textColor: textColor,
                cardColor: cardColor,
              ),

              profileCard(
                  icon: Icons.star,
                  title: "Codechef Stars",
                  value: ccStars?.toString() ?? "--",
                  textColor: textColor,
                  cardColor: cardColor),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  loadUser();
                },
                child:
                const Text(
                  "Refresh",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}