import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String assetPath;
  final Color accentColor;
  final VoidCallback? onOkPressed;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.assetPath,
    required this.accentColor,
    this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              assetPath,
              width: 72,
              height: 72,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  if (onOkPressed != null) {
                    onOkPressed!();
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Ok'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCustomAlert({
  required BuildContext context,
  required String title,
  required String message,
  required String assetPath,
  required Color accentColor,
  VoidCallback? onOkPressed,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => CustomAlertDialog(
      title: title,
      message: message,
      assetPath: assetPath,
      accentColor: accentColor,
      onOkPressed: onOkPressed,
    ),
  );
}
