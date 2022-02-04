import 'package:flutter/material.dart';

class EnclosedBox extends StatelessWidget {

  final List<dynamic> results;
  final int previewH; 
  final int previewW;
  final double screenH;
  final double screenW;

  EnclosedBox(this.results, this.previewH, this.previewW, this.screenH, this.screenW);
  // for the live feed
  List<Widget> _renderStrings() {
      double offset = -10;
      return results.map((re) {
        offset = offset + 30; // space between the 2 options
        print ( results );
        return Positioned(
          left: 10,  // position
          top: offset,
          width: screenW,
          height: screenH,
          child: Text(
            "${re["label"].toString().substring(2)} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              color: Colors.black, // collor letter
              fontSize: 20.0, // how big are the letters
              fontWeight: FontWeight.normal, // normal front size
            ),
          ),
        );
      }).toList();
    }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _renderStrings(),
    );
  }
}
