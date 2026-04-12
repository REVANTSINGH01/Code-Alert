import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),

            const SizedBox(height: 10),

            const Text(
              "Revant Singh",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const Text(
              "Competitive Programmer",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: Icon(Icons.code),
                title: Text("LeetCode Rating"),
                trailing: Text("1850"),
              ),
            ),

            Card(
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text("Codeforces Rating"),
                trailing: Text("1600"),
              ),
            ),

            Card(
              child: ListTile(
                leading: Icon(Icons.notifications),
                title: Text("Active Reminders"),
                trailing: Text("3"),
              ),
            ),

            Card(
              child: ListTile(
                leading: Icon(Icons.people),
                title: Text("Friends"),
                trailing: Text("5"),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Edit Profile"),
            )
          ],
        ),
      ),
    );
  }
}