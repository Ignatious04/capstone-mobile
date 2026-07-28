import 'dart:io';
import 'package:capstone/core/enums/guidance_type_enum.dart';
import 'package:capstone/features/reporting/models/report_model.dart';
import 'package:capstone/features/reporting/models/victim_model.dart';
import 'package:capstone/features/reporting/providers/pending_attachments_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

final reportProvider = NotifierProvider<ReportNotifier, ReportModel>(
  ReportNotifier.new,
);

class ReportNotifier extends Notifier<ReportModel> {
  @override
  ReportModel build() {
    return const ReportModel();
  }

  void setEmergencyType(GuidanceTypeEnum value) {
    state = state.copyWith(type: value);
  }

  void setLocation(LatLng location) {
  state = state.copyWith(
    location: GeoPoint(
      location.latitude,
      location.longitude,
    ),
  );
}

  void addVictim() {
    state = state.copyWith(
      victims: [
        ...state.victims,
        const VictimModel(),
      ],
    );
  }

  void removeVictim(int index) {
    final victims = [...state.victims];
    victims.removeAt(index);
    state = state.copyWith(victims: victims);
  }

  void updateVictimName(int index, String value) {
    final victims = [...state.victims];

    victims[index] = victims[index].copyWith(
      name: value,
    );

    state = state.copyWith(victims: victims);
  }

  void updateVictimDescription(int index, String value) {
    final victims = [...state.victims];

    victims[index] = victims[index].copyWith(
      description: value,
    );

    state = state.copyWith(victims: victims);
  }

  Future<void> addAttachment(ImageSource source) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: source);

    if (image == null) return;

    final file = File(image.path);

    ref
        .read(pendingAttachmentsProvider.notifier)
        .update(
          (state) => [...state, file],
        );
  }

  void removeAttachment(int index) {
    ref.read(pendingAttachmentsProvider.notifier).update(
      (state) {
        final attachments = [...state];
        attachments.removeAt(index);
        return attachments;
      },
    );
  }
}
