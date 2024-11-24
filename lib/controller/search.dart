import 'package:get/get.dart';

class SearchBarController extends GetxController {
  var isSearching = false.obs;

  void toggleSearch() {
    isSearching.value = !isSearching.value;
  }
}
