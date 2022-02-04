import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'camera_view.dart';
import 'painters/face_detector_painter.dart';
import 'package:buddy_bot_cam/main.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  _FaceDetectorViewState createState() => _FaceDetectorViewState();
}
// 
class _FaceDetectorViewState extends State<FaceDetectorView> {
  // No extra features are turned on
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector();

  /*GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
  ));*/
  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Buddy Bot Face Detector Demo',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.front,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    print('Found ${faces.length} faces');
    if (faces.length == 0) {
      x = 0;
      y = 0;
      xWord = "Geen gezicht in beeld";
      yWord = "";
    }
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {

      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);

      customPaint = CustomPaint(painter: painter, size: Size (300, 400),);////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      //  print the approximate center of the face iff a face has been detected
      if (faces.isNotEmpty) {
        x = faces.first.boundingBox.center.dx;
        y = faces.first.boundingBox.center.dy;
        if (x > 100)
          xWord = "Links";
        else if (x < 100 && x > 200)
          xWord = "Midden";
        else
          xWord = "Rechts";

        if (y < 40)
          yWord = "Boven";
        else if (y > 40 && y < 60)
          yWord = "Midden";
        else
          yWord = "Onder";
        print(faces.first.boundingBox.center);
      }
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
