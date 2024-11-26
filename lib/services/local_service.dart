import 'package:get_storage/get_storage.dart';

enum UserboxKey { imageUrl, isLoggedIn, userName, userId, phNumber }

class LocalService {
  static GetStorage get box => GetStorage();
  static bool? isLoggedIn;
  static String? imageUrl;
  static String? userName;
  static String? userId;
  static String? phNumber;

  // Initialize the storage
  static void onInit() {
    // Initialize box if it's not initialized yet
    if (!box.hasData(UserboxKey.isLoggedIn.name)) {
      // If no data, set default values
      box.write(UserboxKey.isLoggedIn.name, false);
    }

    // Load initial values from the storage into static variables
    isLoggedIn = box.read(UserboxKey.isLoggedIn.name);
    imageUrl = box.read(UserboxKey.imageUrl.name);
    userName = box.read(UserboxKey.userName.name);
    userId = box.read(UserboxKey.userId.name);
    phNumber = box.read(UserboxKey.phNumber.name);
  }

  // Function to get data from storage and return it
  static void getData() {
    // If needed, you can add some logic here to update UI or perform actions
    isLoggedIn = box.read(UserboxKey.isLoggedIn.name);
    imageUrl = box.read(UserboxKey.imageUrl.name);
    userName = box.read(UserboxKey.userName.name);
    userId = box.read(UserboxKey.userId.name);
    phNumber = box.read(UserboxKey.phNumber.name);
  }

  // Set profile data in storage and local variables
  static void setProfileData(
      {required String kimageUrl,
      required String kuserName,
      required String kphNumber}) async {
    await box.write(UserboxKey.imageUrl.name, kimageUrl);
    await box.write(UserboxKey.userName.name, kuserName);
    await box.write(UserboxKey.userId.name, kphNumber);
    await box.write(UserboxKey.phNumber.name, kphNumber);

    imageUrl = kimageUrl;
    userName = kuserName;
    userId = kphNumber;
    phNumber = kphNumber;
  }

  // Set login status in storage and local variable
  static void setLoginStatus(bool kisLoggedIn) async {
    await box.write(UserboxKey.isLoggedIn.name, kisLoggedIn);
    isLoggedIn = kisLoggedIn;
  }

  static void clearDataOnLogout() async {
    await box.remove(UserboxKey.imageUrl.name);
    await box.remove(UserboxKey.userName.name);
    await box.remove(
      UserboxKey.userId.name,
    );
    await box.remove(
      UserboxKey.phNumber.name,
    );
    setLoginStatus(false);
  }
}
