import 'package:capstone/core/shared/models/shift_exception_model.dart';
import 'package:capstone/core/shared/models/shift_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ShiftRepository {
  final FirebaseFirestore _firestore;

  ShiftRepository(this._firestore);

  // whereIn accepts at most 30 values (the responder's ID + their team IDs).
  Query<Map<String, dynamic>> _byOwners(String collection, List<String> ownerIDs) =>
      _firestore.collection(collection).where('ownerID', whereIn: ownerIDs.take(30).toList());

  Stream<List<ShiftModel>> watchShiftsForOwners(List<String> ownerIDs) {
    if (ownerIDs.isEmpty) return Stream.value(const []);

    return _byOwners('shifts', ownerIDs).snapshots().map((snapshot) {
      final shifts = <ShiftModel>[];
      for (final doc in snapshot.docs) {
        try {
          shifts.add(ShiftModel.fromMap(doc.data(), doc.id));
        } on FormatException catch (e) {
          debugPrint('Skipping malformed shift: ${e.message}');
        }
      }
      return shifts;
    });
  }

  Stream<List<ShiftExceptionModel>> watchExceptionsForOwners(List<String> ownerIDs) {
    if (ownerIDs.isEmpty) return Stream.value(const []);

    return _byOwners('shiftExceptions', ownerIDs).snapshots().map((snapshot) {
      final exceptions = <ShiftExceptionModel>[];
      for (final doc in snapshot.docs) {
        try {
          exceptions.add(ShiftExceptionModel.fromMap(doc.data(), doc.id));
        } on FormatException catch (e) {
          debugPrint('Skipping malformed shift exception: ${e.message}');
        }
      }
      return exceptions;
    });
  }
}