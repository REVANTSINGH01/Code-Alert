import 'package:flutter/material.dart';
import 'package:my_app/pages/platform_detail.dart';

class UserSetup extends StatefulWidget {
  const UserSetup({super.key});

  @override
  State<UserSetup> createState() => _UserState();
}

class _UserState extends State<UserSetup>{
  final titles = [

    "Codeforces",
    "LeetCode",
    "CodeChef",
    "AtCoder",
  ];
  List<String> selectedPlatforms = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Setup"),
      ),

      body: Column(
        children: [
          Flexible(
            child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount:titles.length,
            itemBuilder: (context, index) {
              final platform=titles[index];
              final bool selected=selectedPlatforms.contains(platform);
              return InkWell(
                onTap:(){
                  setState(() {
                    if (selected) {
                      selectedPlatforms.remove(platform);
                    }
                    else {
                      selectedPlatforms.add(platform);
                    }
                  });
                  print("Clicked $index");
                },
                child:Container(
                  decoration: BoxDecoration(
                    color:selected?Colors.green:Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      titles[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                onPressed: selectedPlatforms.isEmpty
                    ? null
                    : () {

                  print(selectedPlatforms);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlatformDetail(
                        selectedPlatforms: List.from(selectedPlatforms),
                      ),
                    ),
                  );
                },
                child: const Text("Continue"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
