import 'package:capstone/core/shared/models/team_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamRepository {
  final FirebaseFirestore firestore;

  TeamRepository(this.firestore);

  /// Teams belonging to one emergency service (station).
  /// Sorted on the client so no composite index is needed.
  Stream<List<TeamModel>> watchTeamsByService(String serviceID) {
    return firestore
        .collection('teams')
        .where('serviceID', isEqualTo: serviceID)
        .snapshots()
        .map((snapshot) {
          final teams = snapshot.docs
              .map((doc) => TeamModel.fromMap(doc.data(), id: doc.id))
              .toList();
          teams.sort((a, b) => a.teamName.toLowerCase().compareTo(b.teamName.toLowerCase()));
          return teams;
        });
  }
}