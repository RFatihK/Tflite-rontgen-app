import 'package:flutter/material.dart';
import 'package:uygulama_odevi/bone_dedector.dart';
import 'package:uygulama_odevi/brain_dedector.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: const [
          BoneDetector(),
          BrainDedector(),
        ],
      ),
    );
  }
}