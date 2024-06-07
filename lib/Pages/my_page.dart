import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 50,
                child: Text("Me"),
              )
            ],
          ),
        )
      ],
    );
  }
}
