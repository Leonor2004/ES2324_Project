class UserProfile {
  final String uid;
  final String username;
  final int contributions;
  final bool isAdmin;
  final int pfp;

  UserProfile({
    required this.uid,
    required this.username,
    required this.contributions,
    required this.isAdmin,
    required this.pfp
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'contributions': contributions,
      'isAdmin': isAdmin,
      'pfp': pfp
    };
  }

  static UserProfile fromJson(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      username: data['username'] ?? '',
      contributions: data['contributions'] ?? 0,
      isAdmin: data['isAdmin'] ?? false,
      pfp: data['pfp'] ?? 1
    );
  }
}
