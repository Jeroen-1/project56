import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppMainPage(),
    );
  }
}

class AppMainPage extends StatefulWidget {
  const AppMainPage({Key? key}) : super(key: key);

  @override
  _AppMainPageState createState() => _AppMainPageState();
}

class _AppMainPageState extends State<AppMainPage> {
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

  /// Limited scalable main page with the camera preview and the eyes
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Container(
            height: 300,
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const Text('Camera preview:',
                        style: TextStyle(fontSize: 20.0, color: Colors.white)),
                    const SizedBox(height: 15),
                    Image.asset('assets/image.png', scale: 2.5, fit: BoxFit.cover),
                  ],
                )
              ],
            ),
          ),
          Container(
            height: 500,
            width: 500,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            // padding: const EdgeInsets.only(bottom: 15.0, left: 5.0),
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
        ]
      ),
      backgroundColor: Colors.grey,
    );
  }

  /// Fully scalable main page with just the eyes
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: GestureDetector(
//           onTap: _togglePlay,
//           child: RiveAnimation.asset(
//             'assets/eyes3.riv',
//             artboard: 'New Artboard',
//             animations: const ['LookingAround'],
//             controllers: [_controller],
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//       backgroundColor: Colors.grey,
//     );
//   }
}

/// Helpful links:
// https://help.rive.app/runtimes/state-machines