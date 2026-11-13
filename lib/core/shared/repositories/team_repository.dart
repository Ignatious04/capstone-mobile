import 'package:capstone/core/shared/models/team_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamRepository {
  final FirebaseFirestore _firestore;

  TeamRepository(this._firestore);

  // Sorted client-side so no composite index is needed.
  List<TeamModel> _toTeams(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final teams = snapshot.docs.map((d) => TeamModel.fromMap(d.id, d.data())).toList();
    teams.sort((a, b) => a.teamName.toLowerCase().compareTo(b.teamName.toLowerCase()));
    return teams;
  }

  Stream<List<TeamModel>> watchTeamsForService(String serviceID) {
    return _firestore.collection('teams').where('serviceID', isEqualTo: serviceID).snapshots().map(_toTeams);
  }

  Stream<List<TeamModel>> watchTeamsForMember(String responderID) {
    return _firestore.collection('teams').where('memberIDs', arrayContains: responderID).snapshots().map(_toTeams);
  }
}