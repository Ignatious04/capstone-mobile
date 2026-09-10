import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) async* {
  // seed with the current state — onConnectivityChanged alone won't emit it
  yield await Connectivity().checkConnectivity();
  yield* Connectivity().onConnectivityChanged;
});