import 'package:flutter/material.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liked You')),
      body: const Center(
        child: Text('People who liked you will appear here.'),
      ),
    );
  }
}
