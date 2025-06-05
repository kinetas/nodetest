import 'package:flutter/material.dart';

class AIPlusButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AIPlusButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.deepPurple,
      child: Icon(Icons.smart_toy),
    );
  }
}