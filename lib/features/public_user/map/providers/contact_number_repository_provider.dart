import 'package:capstone/features/public_user/map/repositories/contact_number_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactNumberRepositoryProvider = Provider((ref) => ContactNumberRepository());
