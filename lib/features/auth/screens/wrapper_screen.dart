import 'package:flutter/material.dart';
class WrapperScreen extends StatelessWidget {
  static const String route = '/';
  const WrapperScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}