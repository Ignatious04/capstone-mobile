import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';

final pendingAttachmentsProvider = StateProvider<List<File>>((ref) => []);
