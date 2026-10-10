import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/features/public_user/reporting/widgets/attachments_card.dart';
import 'package:capstone/features/responder/active_case/providers/responder_attachment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ResponderAttachmentsSection extends ConsumerWidget {
  const ResponderAttachmentsSection({super.key, required this.report});

  final ReportModel report;

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    final error = await ref
        .read(responderAttachmentProvider.notifier)
        .addImage(reportID: report.reportID, source: source);

    if (error != null && context.mounted) {
      CustomSnackbarHelper.show(context, text: error, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUploading = ref.watch(responderAttachmentProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(icon: Icons.add_a_photo_outlined, title: 'Responder Attachments'),
        const SizedBox(height: 10),
        AttachmentsCard(attachments: report.responderAttachments),
        const SizedBox(height: 10),
        CustomElevatedButton(
          onPressed: isUploading ? null : () => _pick(context, ref),
          value: isUploading ? 'Uploading...' : 'Add image',
          icon: isUploading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.add_a_photo),
        ),
      ],
    );
  }
}