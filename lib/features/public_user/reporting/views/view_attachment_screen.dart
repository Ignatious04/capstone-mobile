import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:flutter/material.dart';

class ViewAttachmentScreen extends StatelessWidget {
  const ViewAttachmentScreen({
    super.key,
    required this.fileName,
    required this.url,
  });

  final String fileName;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(value: fileName),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder:
              (
                context,
                child,
              ) {
                return const Center(
                  child: CustomCircularProgressIndicator(),
                );
              },
          errorWidget:
              (
                context,
                error,
                stackTrace,
              ) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 36,
                    color: Colors.white,
                  ),
                );
              },
        ),
      ),
    );
  }
}
