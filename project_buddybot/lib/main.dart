import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const BuddyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}

class BuddyApp extends StatelessWidget {
  const BuddyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project56',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: const EyesAnimation(),

    );
  }
}

class EyesAnimation extends StatefulWidget {
  const EyesAnimation({Key? key}) : super(key: key);

  @override
  _EyesAnimationState createState() => _EyesAnimationState();
}

class _EyesAnimationState extends State<EyesAnimation> {
  /// Controller for playback
  late RiveAnimationController _controller;

  /// Toggles between play and pause animation states
  void _togglePlay() => _controller.isActive = !_controller.isActive;

  @override
  void initState() {
    super.initState();
    _controller = OneShotAnimation('Happy', autoplay: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: _togglePlay,
          child: RiveAnimation.asset(
            'assets/eyes3.riv',
            artboard: 'New Artboard',
            animations: const ['LookingAround'],
            controllers: [_controller],
            fit: BoxFit.cover,
          ),
        ),
      ),
      backgroundColor: Colors.grey,
    );
  }
}