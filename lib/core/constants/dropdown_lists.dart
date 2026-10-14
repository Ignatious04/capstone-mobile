import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';

class DropdownLists {
  static const sexItems = [
    DropdownMenuItem(
      value: "Male",
      child: BodyText(value: "Male"),
    ),
    DropdownMenuItem(
      value: "Female",
      child: BodyText(value: "Female"),
    ),
  ];

  static const nationalityItems = [
    DropdownMenuItem(
      value: "Filipino",
      child: BodyText(value: "Filipino"),
    ),
    DropdownMenuItem(
      value: "American",
      child: BodyText(value: "American"),
    ),
  ];

  static const civilStatusItems = [
    DropdownMenuItem(
      value: "Single",
      child: BodyText(value: "Single"),
    ),
    DropdownMenuItem(
      value: "Married",
      child: BodyText(value: "Married"),
    ),
    DropdownMenuItem(
      value: "Widowed",
      child: BodyText(value: "Widowed"),
    ),
  ];

  static const barangays = [
    'Agapito del Rosario',
    'Amsic',
    'Anunas',
    'Balibago',
    'Capaya',
    'Claro M. Recto',
    'Cuayan',
    'Cutud',
    'Lourdes North West',
    'Lourdes Sur (Talimundoc)',
    'Lourdes Sur East',
    'Malabañas (Malabanias)',
    'Margot',
    'Mining',
    'Marisol (Ninoy Aquino)',
    'Pampang (Santo Niño)',
    'Pandan',
    'Pulung Bulu (Pulungbulu)',
    'Pulung Cacutud',
    'Pulung Maragul',
    'Salapungan',
    'San José',
    'San Nicolas',
    'Santa Teresita',
    'Santa Trinidad',
    'Santo Cristo',
    'Santo Domingo',
    'Santo Rosario',
    'Sapalibutad',
    'Sapangbato',
    'Tabun',
    'Virgen Delos Remedios',
  ];

  static const religions = [
    DropdownMenuItem(
      value: "Iglesia ni Cristo",
      child: BodyText(value: "Iglesia ni Cristo"),
    ),
    DropdownMenuItem(
      value: "Islam",
      child: BodyText(value: "Islam"),
    ),
    DropdownMenuItem(
      value: "Roman Catholic",
      child: BodyText(value: "Roman Catholic"),
    ),
  ];

  static const vaccineItems = [
    DropdownMenuItem(
      value: "Anti-Rabies",
      child: Text("Anti-Rabies"),
    ),
  ];
}
