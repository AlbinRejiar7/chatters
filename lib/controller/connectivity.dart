import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Controller to monitor the internet connectivity status
class ConnectivityController extends GetxController {
  // Observable to hold the connectivity status (true: connected, false: disconnected)
  var isConnected = false.obs;

  // List to store the current connectivity results (WiFi, Mobile, None)
  final List<ConnectivityResult> connectivityResults =
      <ConnectivityResult>[].obs;

  // Connectivity instance to check connection status and listen for changes
  final Connectivity connectivity = Connectivity();

  // StreamSubscription to listen for connectivity changes
  late StreamSubscription<List<ConnectivityResult>> subscription;

  @override
  void onInit() {
    super.onInit();

    // Initialize connectivity checking
    initConnectivity();

    // Optional: Uncomment to show a snackbar when there's no internet connection
    // ever(isConnected, (bool connected) {
    //   if (!connected) {
    //     Get.snackbar(
    //       'No Internet Connection',
    //       'Please check your internet settings',
    //       snackPosition: SnackPosition.TOP,
    //     );
    //   }
    // });
  }

  /// Initializes the connectivity listener and checks the initial connectivity status
  Future<void> initConnectivity() async {
    // Listen for connectivity changes
    subscription = connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      // Update connection status whenever it changes
      updateConnectionStatus(result);
    });

    try {
      // Check the initial connectivity status (WiFi, Mobile, None)
      var initialStatus = await connectivity.checkConnectivity();
      updateConnectionStatus(
          initialStatus); // Pass the initial status as a list
    } on PlatformException catch (e) {
      // Handle errors when checking connectivity (e.g., if permissions are not granted)
      debugPrint('Couldn\'t check connectivity status: ${e.toString()}');
    }
  }

  /// Updates the connection status based on the list of connectivity results
  ///
  /// [result] - List of connectivity results (e.g., WiFi, Mobile, None).
  /// Updates the [isConnected] observable based on whether any connection exists.
  void updateConnectionStatus(List<ConnectivityResult> result) {
    // Clear any previous connectivity results
    connectivityResults.clear();

    // Check if there's no connectivity (no WiFi or mobile data)
    if (result.contains(ConnectivityResult.none)) {
      connectivityResults.add(ConnectivityResult.none); // Store "none" status
      isConnected.value = false; // Set isConnected to false
    } else {
      // If there is WiFi connection, add it to the results
      if (result.contains(ConnectivityResult.wifi)) {
        connectivityResults.add(ConnectivityResult.wifi);
      }

      // If there is mobile data connection, add it to the results
      if (result.contains(ConnectivityResult.mobile)) {
        connectivityResults.add(ConnectivityResult.mobile);
      }

      // Set isConnected to true if there's any active connection
      isConnected.value = connectivityResults.isNotEmpty &&
          !connectivityResults.contains(ConnectivityResult.none);
    }

    // Debugging: Log the updated connection status
    debugPrint('Connectivity changed: $isConnected');
  }

  @override
  void dispose() {
    // Cancel the connectivity subscription when the controller is disposed to prevent memory leaks
    subscription.cancel();
    super.dispose();
  }
}
