import 'package:capstone/features/public_user/map/models/emergency_service_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyServicesRepository {
  final FirebaseFirestore _firestore;

  EmergencyServicesRepository(this._firestore);

  Stream<List<EmergencyServiceModel>> watchServices() {
    return _firestore
        .collection('emergencyServices')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EmergencyServiceModel.fromMap(doc.data(), id: doc.id),
              )
              .toList(),
        );
  }
}
