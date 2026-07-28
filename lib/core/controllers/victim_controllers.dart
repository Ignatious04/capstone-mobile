import 'package:flutter/material.dart';

class VictimControllers {
  TextEditingController victimNameController = TextEditingController();
  TextEditingController victimDescriptionController = TextEditingController();

  void dispose() {
    victimNameController.dispose();
    victimDescriptionController.dispose();
  }
}
