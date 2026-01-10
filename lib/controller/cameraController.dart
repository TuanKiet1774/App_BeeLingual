import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class CameraScanController extends ChangeNotifier {
  CameraController? cameraController;
  XFile? capturedImage;

  Rect scanRect = const Rect.fromLTWH(50, 150, 300, 200);

  final double minSize = 60;
  final ImagePicker picker = ImagePicker();

  int rotation = 0;

  /// INIT CAMERA
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController!.initialize();
    notifyListeners();
  }

  void disposeCamera() {
    cameraController?.dispose();
  }

  /// ROTATE IMAGE
  void rotateImage() {
    rotation = (rotation + 90) % 360;
    notifyListeners();
  }

  /// MOVE SCAN RECT
  void moveRect(Offset delta, Size screenSize) {
    final left =
    (scanRect.left + delta.dx).clamp(0.0, screenSize.width - scanRect.width);
    final top =
    (scanRect.top + delta.dy).clamp(0.0, screenSize.height - scanRect.height);

    scanRect = Rect.fromLTWH(left, top, scanRect.width, scanRect.height);
    notifyListeners();
  }

  /// RESIZE RECT
  void resizeRect({
    required Rect Function(Rect old) update,
  }) {
    scanRect = update(scanRect);
    notifyListeners();
  }

  /// CAPTURE
  Future<void> captureImage() async {
    final pic = await cameraController!.takePicture();
    capturedImage = pic;
    rotation = 0;
    notifyListeners();
  }

  /// PICK GALLERY
  Future<void> pickFromGallery() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      capturedImage = img;
      rotation = 0;
      notifyListeners();
    }
  }

  /// OCR PROCESS
  Future<String> processImage(Size screenSize) async {
    final cropped = await _cropImage(
      File(capturedImage!.path),
      scanRect,
      screenSize,
      rotation: rotation,
    );

    final input = InputImage.fromFile(cropped);
    final recognizer =
    TextRecognizer(script: TextRecognitionScript.latin);

    final result = await recognizer.processImage(input);
    await recognizer.close();

    return result.text;
  }

  /// CROP IMAGE
  Future<File> _cropImage(
      File file,
      Rect rect,
      Size screenSize, {
        int rotation = 0,
      }) async {
    final bytes = await file.readAsBytes();
    img.Image original = img.decodeImage(bytes)!;

    if (rotation != 0) {
      original = img.copyRotate(original, angle: rotation);
    }

    final scaleX = original.width / screenSize.width;
    final scaleY = original.height / screenSize.height;

    final cropped = img.copyCrop(
      original,
      x: (rect.left * scaleX).toInt(),
      y: (rect.top * scaleY).toInt(),
      width: (rect.width * scaleX).toInt(),
      height: (rect.height * scaleY).toInt(),
    );

    final out = File('${file.path}_crop.jpg');
    await out.writeAsBytes(img.encodeJpg(cropped));
    return out;
  }
}
