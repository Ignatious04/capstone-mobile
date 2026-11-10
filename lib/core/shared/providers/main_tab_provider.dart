import 'package:flutter_riverpod/flutter_riverpod.dart';

const kReportsTabIndex = 1;
const kGuidanceTabIndex = 3;

class MainTabNotifier extends Notifier<int> {
  @override
  int build() => 0; // Home

  void set(int index) => state = index;
}

final mainTabProvider = NotifierProvider.autoDispose<MainTabNotifier, int>(
  MainTabNotifier.new,
);
