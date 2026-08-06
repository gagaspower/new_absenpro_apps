import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyStateWidget extends StatelessWidget {
  final String assetPath;
  final String title;
  final String? subtitle;
  final double imageSize;

  const EmptyStateWidget({
    super.key,
    required this.assetPath,
    required this.title,
    this.subtitle,
    this.imageSize = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              assetPath,
              width: imageSize,
              height: imageSize,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black38, fontSize: 13),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
