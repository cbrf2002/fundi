import 'package:flutter/material.dart';

class CircleGradientBackground extends StatelessWidget {
  const CircleGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Image.asset(
            'lib/assets/images/ell2.png',
            width: 500,
            height: 500,
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Transform.rotate(
            angle: 3.14159, // 180 degrees in radians
            child: Image.asset(
              'lib/assets/images/ell2.png',
              width: 500,
              height: 500,
            ),
          ),
        ),
      ],
    );
  }
}
