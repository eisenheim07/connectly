import 'package:connectly/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    
    return const Scaffold(
      body: Center(
        child: Text('Home Screen'),
      ),
      appBar: CustomAppBar(title: "Connectly"),
    );
  }
}
