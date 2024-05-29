import 'package:flutter/material.dart';

import '../config/app_assets.dart';

class ErrorBackground extends StatelessWidget {
  const ErrorBackground(
      {super.key, required this.ratio, required this.message});
  final double ratio;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ratio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              AppAssets.emptyBG,
              fit: BoxFit.cover,
            ),
          ),
          UnconstrainedBox(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              alignment: Alignment.center,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
