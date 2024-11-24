import 'package:get/get.dart';

class CountrySelectorController extends GetxController {
  var selectedCountry = '91'.obs;
  void onSelectedCountry(String selectedValue) {
    selectedCountry(selectedValue);
  }
}
