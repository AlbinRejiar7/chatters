import "dart:convert";
import "dart:developer";

import "package:chatter/services/local_notification.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class PushNotificationService {
  static FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "chattingapp-4e42e",
      "private_key_id": "a08e9b28b13b4b767bcde98031a1c7b1a159327d",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCddwGEjLIpKwuS\nvSBVwV83tKYD3o/s8zsjIDuzB3vjAlnK8wkFvbz3rHbYx6VK6oZfdYIcWbkT39y2\nB66EGrcMWgZeXhGxlXfAYV2TfhixsUR+34+te+0k9eBq1S8NtIz9l4r8MvK8qU4g\neU1uN25zqoRRLQT95hWlSq9RADyM5/LDvfQh1o0i96XMNcIr6CWIBy8LihNNWG/P\nwjI10ySs3sFtHiWdUd+ZxWD0+iwxFp0siXSomYrvl9lAT1GXb6OGaWxY8TJkV7uw\n2cFeh6h4MeAMAvo7LpPnxdB5q46abky5xAY1MRJwQhGsZxUdu/oXMhdgsyCb76B3\n21UtCiMHAgMBAAECggEAAI94/pw78OXbwZvYbPYQ+Zd1kt9w1oUX8hE/mh/o/o8I\n8yhsh3mDVA3wzzELP/O7iU1JOMmFXUH//jOvzBz+DO0akSpqkWqgj4SsCo6Uoutm\n9xudGiHYtMA55ycVKEpXYsoeuQoGZ5zOVuyPbGbsTfieUXnpgppR2dM2A2VhRmm6\nj6PnyFyWi6ePc0HQ0Lo5hMvcGXedMOPEn1mHNIyEKDSDRGtEdfeqnUsbzPYc3ejv\nLf8c4rxWUMH5HmfF/johRaMNYLl7omVgHTeJNRnDT+9VK7GuNlisv6AjSnFqJC2j\ntZ+XBO4Sa3hdhUuEPodzh4zjgpw5UnheYdxi5JnHQQKBgQDYlTTsWflPytz91VJB\nApixRv8gO0CI8GT0JSRLbkV7+V3YJ/936namXn8mBH6Pz5bsT89BCoz8GT6b8TBT\nBocjRU+yVNM4okkzZk0aQAg5XV0RBeBB5m8HxQhV1X7ajHZfUFNWJWP/WxQ+5Hw1\nHQsWD2jH+dVsYo2EL5zie1t0wQKBgQC6H3BJcqgQQ1F0Ajr+eVLXoPDU9Ry13n1q\nExrlah6b5dnzEF1hbqvOgywnFUJTl1YhkSEhgQZ9artrTlyEf4ezpFAiecCJkSVZ\nddiV+3JVypQWDVwNQsmjSvLDc5XsPhvziaWKdNFvMM3DyeOAxi+8KietoVNoH97B\nGHaw7MWhxwKBgF8cRv10FZQA1kNyJoj+Bufy8Z7J5nE8gFjm5qVpa4Ih5CBEkF+s\nyyYMYXHkj1/AHdrwwWcipv8eZuw8YqhTOY03puP9dDRusA6uYjWg4PuwEGqlVfIa\nq6+RyzNGakq3XFRHBhHSobNF4AIufI0mj/PEGJOZFyxdqx/deNvMqEEBAoGBAKTj\nbUrkdNfTi7nGsBT5ztaREkrXy9OjhGARBObxmKRsgSXA/blvnm2Z7+fAAb6kd/3M\n4RkZgXJiuB9ckMIhaUtQ6l1gl55IJFqY+IQG+0fd7EuNElv9Kz2rDF7za4Kbk4+y\nBiIfU9u51ND7br2K1odQoU5FeerpMSLIVX5whLXJAoGAJBd2z4IruFxQ1xDhX4qd\n53IWFpRoBQ1vWEPI+IJOkgFMIFrRBqsErbN8tByv3yP5x+T1jPqgHZkIj8Ww9yKq\nQl/bC4yfO8q0lUxMDZZ0XXqDy5VDJR0v0QKEHy01vHWGvM+fGYlb0fUWE00ygScr\nWsKiet1m/z1akHnlKXLxIyo=\n-----END PRIVATE KEY-----\n",
      "client_email": "chatterapp@chattingapp-4e42e.iam.gserviceaccount.com",
      "client_id": "104515590187315543058",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/chatterapp%40chattingapp-4e42e.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    var credentials =
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
    var client = http.Client();

    try {
      var accessCredentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
              credentials, scopes, client);
      return accessCredentials.accessToken.data;
    } finally {
      client.close();
    }
  }

  static Future<void> sendNotification(
      {required String topicId,
      required String body,
      required String title}) async {
    try {
      final String serverKey = await getAccessToken();

      String endpointFCM =
          "https://fcm.googleapis.com/v1/projects/chattingapp-4e42e/messages:send";

      var message = {
        'message': {
          'topic': topicId,
          'notification': {
            'title': title,
            'body': body,
          },
          // 'data': {'dataId': "dasfesr32423532tfd"}
        }
      };

      final response = await http.post(
        Uri.parse(endpointFCM),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey'
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        log("NOTIFICATION SENT SUCCESSFULLY");
      } else {
        // errorToast(msg: "Failed to send notification: ${response.statusCode}");
        log(response.body); // Log the response body for more details
      }
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  static subscribeToTopic(String topic) async {
    log(topic + "Subcribed to this topic");
    // await NotificationPermissionHandler.requestNotificationPermission();
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  static Future<void> handleForegroundNotification() async {
    FirebaseMessaging.onMessage.listen(
      (event) async {
        log(" handleForegroundNotification message recieved!!!!!!!!");
        if (event.notification != null) {
          await LocalNotificationService.showNotification(
            id: 0,
            title: event.notification?.title ?? "",
            body: event.notification?.body ?? "",
            payload: event.notification?.title ?? "",
          );
        }
      },
    );
  }

  static Future<void> handleBackgroundNotification() async {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (event) async {
        log(" handleBackgroundNotification message recieved!!!!!!!!");
        if (event.notification != null) {
          await LocalNotificationService.showNotification(
            id: 0,
            title: event.notification?.title ?? "",
            body: event.notification?.body ?? "",
            payload: event.notification?.title ?? "",
          );
        }
      },
    );
  }

  // unsubscribeFromAllTopics() async {
  //   for (String topic in LocalService.subscribedTopics) {
  //     await _firebaseMessaging.unsubscribeFromTopic(topic);
  //   }
  //   LocalService.subscribedTopics.clear();
  //   await LocalService.saveSubscribedTopics();
  // }
}
