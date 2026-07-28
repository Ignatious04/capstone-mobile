import 'package:flutter/material.dart';

class LoadingOverlayWidget extends StatelessWidget {
  const LoadingOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black45,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
