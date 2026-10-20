import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:flutter/material.dart';

class ViewAttachmentScreen extends StatelessWidget {
  /// An uploaded attachment, loaded from its download URL.
  const ViewAttachmentScreen({
    super.key,
    required this.fileName,
    required String this.url,
  }) : file = null;

  /// An image that hasn't been uploaded yet (e.g. on the report form).
  const ViewAttachmentScreen.file({
    super.key,
    required this.fileName,
    required File this.file,
  }) : url = null;

  final String fileName;
  final String? url;
  final File? file;

  static const _brokenImage = Center(
    child: Icon(
      Icons.broken_image_outlined,
      size: 36,
      color: Colors.black54,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final image = file != null
        ? Image.file(
            file!,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _brokenImage,
          )
        : CachedNetworkImage(
            imageUrl: url!,
            fit: BoxFit.contain,
            placeholder: (context, child) => const Center(
              child: CustomCircularProgressIndicator(),
            ),
            errorWidget: (context, error, stackTrace) => _brokenImage,
          );

    return Scaffold(
      appBar: CustomAppBar(value: fileName),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(child: image),
      ),
    );
  }
}