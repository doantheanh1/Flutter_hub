import 'package:flutter/material.dart';

class HomePageViewModern extends StatelessWidget {
  const HomePageViewModern({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Modern UI'),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Modern UI Coming Soon!',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
