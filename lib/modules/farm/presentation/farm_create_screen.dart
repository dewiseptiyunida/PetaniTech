import 'package:flutter/material.dart';

class FarmCreateScreen extends StatelessWidget {
  const FarmCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Area Create')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Area Create')],
        ),
      ),
    );
  }
}
