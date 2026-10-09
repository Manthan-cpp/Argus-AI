import 'package:flutter/material.dart';

class ZoneWebcamPreview extends StatelessWidget {
  const ZoneWebcamPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B101B),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_rounded, size: 44, color: Colors.white30),
            SizedBox(height: 10),
            Text(
              'Webcam Live Feed (Native / Desktop preview)',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
