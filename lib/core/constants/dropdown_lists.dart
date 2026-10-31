import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';

/// `value` is what gets stored (English); the child is what the user sees.
class DropdownLists {
  static List<DropdownMenuItem<String>> sexItems(AppLocalizations l10n) => [
    DropdownMenuItem(
      value: "Male",
      child: BodyText(value: l10n.sexMale),
    ),
    DropdownMenuItem(
      value: "Female",
      child: BodyText(value: l10n.sexFemale),
    ),
  ];

  static List<DropdownMenuItem<String>> nationalityItems(AppLocalizations l10n) => [
    DropdownMenuItem(
      value: "Filipino",
      child: BodyText(value: l10n.nationalityFilipino),
    ),
    DropdownMenuItem(
      value: "American",
      child: BodyText(value: l10n.nationalityAmerican),
    ),
  ];

  static List<DropdownMenuItem<String>> civilStatusItems(AppLocalizations l10n) => [
    DropdownMenuItem(
      value: "Single",
      child: BodyText(value: l10n.civilSingle),
    ),
    DropdownMenuItem(
      value: "Married",
      child: BodyText(value: l10n.civilMarried),
    ),
    DropdownMenuItem(
      value: "Widowed",
      child: BodyText(value: l10n.civilWidowed),
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

  static List<DropdownMenuItem<String>> religions(AppLocalizations l10n) => [
    DropdownMenuItem(
      value: "Iglesia ni Cristo",
      child: BodyText(value: l10n.religionIglesia),
    ),
    DropdownMenuItem(
      value: "Islam",
      child: BodyText(value: l10n.religionIslam),
    ),
    DropdownMenuItem(
      value: "Roman Catholic",
      child: BodyText(value: l10n.religionCatholic),
    ),
  ];

  static List<DropdownMenuItem<String>> vaccineItems(AppLocalizations l10n) => [
    DropdownMenuItem(
      value: "Anti-Rabies",
      child: Text(l10n.vaccineAntiRabies),
    ),
  ];

  static const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
}
