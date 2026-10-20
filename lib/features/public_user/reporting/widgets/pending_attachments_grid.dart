import 'dart:io';

import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/view_attachment_screen.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

/// Thumbnails of the images queued on the report form. Same 2-column grid as
/// [AttachmentsCard] (what the user sees once the report is sent), plus a
/// remove button on each tile since these haven't been uploaded yet.
class PendingAttachmentsGrid extends StatelessWidget {
  const PendingAttachmentsGrid({
    super.key,
    required this.files,
    required this.onRemove,
  });

  final List<File> files;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final file = files[index];

        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewAttachmentScreen.file(
                      fileName: path.basename(file.path),
                      file: file,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: AppColors.lighterBlack,
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                    // Photos are up to 1920px wide; decode at thumbnail size.
                    cacheWidth: 400,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: l10n.removeAttachment,
                onPressed: () => onRemove(index),
                iconSize: 18,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        );
      },
    );
  }
}