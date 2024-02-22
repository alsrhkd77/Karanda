import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MarettaMapViewer extends StatelessWidget {
  const MarettaMapViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          InteractiveViewer(
            maxScale: 4.5,
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Image.asset(
                'assets/image/Black_desert_ocean_map(v1.2).jpg',
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
