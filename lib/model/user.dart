class UserModel {
  String id; // Unique identifier for the user
  String username; // Display name of the user
  String? email; // Optional email address
  String? phoneNumber; // Optional phone number
  String? profileImageUrl; // URL for the user's profile picture
  String? bio; // Short bio for the user
  bool isOnline; // Indicates if the user is currently online
  DateTime lastSeen; // Timestamp of the user's last activity
  List<String> blockedUsers; // List of user IDs blocked by this user
  DateTime createdAt; // When the user account was created
  DateTime updatedAt; // When the user account was last updated

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.bio,
    required this.isOnline,
    required this.lastSeen,
    this.blockedUsers = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a UserModel from a Map (e.g., Firebase Firestore data)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      bio: map['bio'] as String?,
      isOnline: map['isOnline'] as bool,
      lastSeen: DateTime.parse(map['lastSeen'] as String),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Method to convert the UserModel to a Map (for saving to Firebase or similar)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'blockedUsers': blockedUsers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
