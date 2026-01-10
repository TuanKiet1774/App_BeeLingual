import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/cameraController.dart';

class CameraScanPage extends StatelessWidget {
  const CameraScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraScanController()..initCamera(),
      child: const _CameraScanView(),
    );
  }
}

class _CameraScanView extends StatelessWidget {
  const _CameraScanView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraScanController>();
    final screenSize = MediaQuery.of(context).size;

    /// ===== AFTER IMAGE =====
    if (controller.capturedImage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Select scan area")),
        body: Stack(
          children: [
            Positioned.fill(
              child: Transform.rotate(
                angle: controller.rotation * pi / 180,
                child: Image.file(
                  File(controller.capturedImage!.path),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: (d) {
                  if (!controller.scanRect.contains(d.localPosition)) return;
                  controller.moveRect(d.delta, screenSize);
                },
                child: CustomPaint(
                  painter: ScanRectPainter(controller.scanRect),
                ),
              ),
            ),

            _buildButtonBar(context, controller, screenSize),
          ],
        ),
      );
    }

    /// ===== CAMERA =====
    if (controller.cameraController == null ||
        !controller.cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: CameraPreview(controller.cameraController!),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: controller.captureImage,
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: controller.pickFromGallery,
                  child: const Icon(Icons.photo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonBar(
      BuildContext context,
      CameraScanController controller,
      Size screenSize,
      ) {
    return Positioned(
      bottom: 55,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.greenAccent,
            child: const Icon(Icons.rotate_right),
            onPressed: controller.rotateImage,
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            backgroundColor: Colors.amber,
            child: const Icon(Icons.check),
            onPressed: () async {
              final text = await controller.processImage(screenSize);
              Navigator.pop(context, text);
            },
          ),
        ],
      ),
    );
  }
}

/// ===== PAINTER =====
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
