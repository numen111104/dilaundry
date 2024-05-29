import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/laundry_model.dart';

final myLaundryStatusProvider = StateProvider.autoDispose((ref) => '');

setMyLaundryStatus(WidgetRef ref, String newStatus) {
  ref.read(myLaundryStatusProvider.notifier).state = newStatus;
}

final myLaundryCategoryProvider = StateProvider.autoDispose((ref) => 'All');

setMyLaundryCategory(WidgetRef ref, String newStatus) {
  ref.read(myLaundryCategoryProvider.notifier).state = newStatus;
}

final myLaundryListProvider =
    StateNotifierProvider.autoDispose<MyLaundryList, List<LaundryModel>>(
  (ref) => MyLaundryList([]),
);

class MyLaundryList extends StateNotifier<List<LaundryModel>> {
  MyLaundryList(super.state);

  setData(List<LaundryModel> newList) {
    state = newList;
  }
}
