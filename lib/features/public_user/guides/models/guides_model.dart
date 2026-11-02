import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class GuideSummary {
  const GuideSummary({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
  });

  final String id; // also the .md file name
  final ServiceTypeEnum type;
  final String title;
  final String summary;

  factory GuideSummary.fromJson(Map<String, dynamic> json) => GuideSummary(
    id: json['id'] as String,
    type: ServiceTypeEnum.values.byName(json['type'] as String),
    title: json['title'] as String,
    summary: json['summary'] as String,
  );
}

extension GuideTypeStyle on ServiceTypeEnum {
  IconData get guideIcon => switch (this) {
    ServiceTypeEnum.medical => Icons.medical_services,
    ServiceTypeEnum.police => Icons.local_police,
    ServiceTypeEnum.fire => Icons.local_fire_department,
  };

  Color get guideColor => switch (this) {
    ServiceTypeEnum.medical => Colors.green,
    ServiceTypeEnum.police => Colors.blue,
    ServiceTypeEnum.fire => Colors.red,
  };

  Color get guideBackground => switch (this) {
    ServiceTypeEnum.medical => AppColors.lighterGreen,
    ServiceTypeEnum.police => AppColors.lighterBlue,
    ServiceTypeEnum.fire => AppColors.lighterRed,
  };
}