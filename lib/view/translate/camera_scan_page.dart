import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  CameraController? _cameraController;
  XFile? capturedImage;

  Rect scanRect = const Rect.fromLTWH(50, 150, 300, 200);
  final double handleSize = 22;
  final double minSize = 60;

  final ImagePicker _picker = ImagePicker();

  int _rotation = 0;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (capturedImage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Select the scan area")),
        body: Stack(
          children: [
            Positioned.fill(
              child: Transform.rotate(
                angle: _rotation * pi / 180,
                child: Image.file(
                  File(capturedImage!.path),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  final pos = details.localPosition;
                  if (!scanRect.contains(pos)) return;

                  setState(() {
                    final left = (scanRect.left + details.delta.dx)
                        .clamp(0.0, screenSize.width - scanRect.width);
                    final top = (scanRect.top + details.delta.dy)
                        .clamp(0.0, screenSize.height - scanRect.height);
                    scanRect =
                        Rect.fromLTWH(left, top, scanRect.width, scanRect.height);
                  });
                },
                child: CustomPaint(
                  painter: ScanRectPainter(scanRect),
                ),
              ),
            ),

            _buildHandle(
              x: scanRect.left,
              y: scanRect.top,
              onDrag: (dx, dy) {
                setState(() {
                  final l = (scanRect.left + dx).clamp(0.0, scanRect.right - minSize);
                  final t = (scanRect.top + dy).clamp(0.0, scanRect.bottom - minSize);
                  scanRect = Rect.fromLTRB(l, t, scanRect.right, scanRect.bottom);
                });
              },
            ),
            _buildHandle(
              x: scanRect.right,
              y: scanRect.top,
              onDrag: (dx, dy) {
                setState(() {
                  final r = (scanRect.right + dx)
                      .clamp(scanRect.left + minSize, screenSize.width);
                  final t = (scanRect.top + dy).clamp(0.0, scanRect.bottom - minSize);
                  scanRect = Rect.fromLTRB(scanRect.left, t, r, scanRect.bottom);
                });
              },
            ),
            _buildHandle(
              x: scanRect.left,
              y: scanRect.bottom,
              onDrag: (dx, dy) {
                setState(() {
                  final l = (scanRect.left + dx).clamp(0.0, scanRect.right - minSize);
                  final b = (scanRect.bottom + dy)
                      .clamp(scanRect.top + minSize, screenSize.height);
                  scanRect = Rect.fromLTRB(l, scanRect.top, scanRect.right, b);
                });
              },
            ),
            _buildHandle(
              x: scanRect.right,
              y: scanRect.bottom,
              onDrag: (dx, dy) {
                setState(() {
                  final r = (scanRect.right + dx)
                      .clamp(scanRect.left + minSize, screenSize.width);
                  final b = (scanRect.bottom + dy)
                      .clamp(scanRect.top + minSize, screenSize.height);
                  scanRect = Rect.fromLTRB(scanRect.left, scanRect.top, r, b);
                });
              },
            ),

            Positioned(
              left: scanRect.left,
              top: scanRect.top - 26,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black54,
                child: Text(
                  "${scanRect.width.toInt()} × ${scanRect.height.toInt()}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            Positioned(
              bottom: 55,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: "rotate",
                    backgroundColor: Colors.lightGreenAccent,
                    child: const Icon(Icons.rotate_right),
                    onPressed: () {
                      setState(() {
                        _rotation = (_rotation + 90) % 360;
                      });
                    },
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: "confirm",
                    backgroundColor: Colors.amber,
                    child: const Icon(Icons.check),
                    onPressed: () => _processImage(
                      capturedImage!,
                      scanRect,
                      screenSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize!.height,
                height: _cameraController!.value.previewSize!.width,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0, // Thêm dòng này
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "cam",
                  child: const Icon(Icons.camera_alt),
                  onPressed: _captureImage,
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: "gallery",
                  child: const Icon(Icons.photo),
                  onPressed: _pickImageFromGallery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle({
    required double x,
    required double y,
    required Function(double dx, double dy) onDrag,
  }) {
    return Positioned(
      left: x - handleSize / 2,
      top: y - handleSize / 2,
      child: GestureDetector(
        onPanUpdate: (d) => onDrag(d.delta.dx, d.delta.dy),
        child: Container(
          width: handleSize,
          height: handleSize,
          decoration: const BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    final pic = await _cameraController!.takePicture();
    setState(() {
      capturedImage = pic;
      _rotation = 0;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        capturedImage = img;
        _rotation = 0;
      });
    }
  }

  Future<void> _processImage(XFile file, Rect rect, Size screenSize) async {
    final cropped = await cropImage(
      File(file.path),
      rect,
      screenSize,
      rotation: _rotation,
    );

    final input = InputImage.fromFile(cropped);
    final recognizer =
    TextRecognizer(script: TextRecognitionScript.latin);

    final text = await recognizer.processImage(input);
    await recognizer.close();

    Navigator.pop(context, text.text);
  }
}

/// ================= PAINTER =================
class ScanRectPainter extends CustomPainter {
  final Rect rect;
  ScanRectPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Future<File> cropImage(
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
