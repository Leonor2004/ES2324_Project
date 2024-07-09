import 'package:firebase_database/firebase_database.dart';
import 'user_profile.dart';

class FirebaseDatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();


  Future<void> createUserProfile(String uid, String username) async {
    await _dbRef.child('users/$uid').set({
      'username': username,
      'contributions': 0,
      'isAdmin': false, // Start with zero contributions
      'pfp':1
    });
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    var snapshot = await _dbRef.child('users/$uid').get();
    if (snapshot.exists) {
      return UserProfile.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map), uid);
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, String username,
      String profilePicture, int contributions, bool isAdmin, int pfp) async {
    await _dbRef.child('users/$uid').update({
      'username': username,
      'contributions': contributions,
      'isAdmin': isAdmin,
      'pfp': pfp,
    });
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DataSnapshot snapshot = await _dbRef.child('users/$uid').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  Future<void> updateUsername(String uid, String newUsername) async {
    try {
      await _dbRef.child('users/$uid/username').set(newUsername);
    } catch (e) {
      print("Error updating username: $e");
      throw Exception("Failed to update username.");
    }
  }

  Future<void> updateContributions(String uid) async {
    try {
        // Reference to the user's contributions
        DatabaseReference contributionsRef = _dbRef.child('users/$uid/contributions');
        
        // Fetch the current contributions value
        DataSnapshot snapshot = await contributionsRef.get();
        int currentContributions = 0;
        if (snapshot.exists && snapshot.value != null) {
            currentContributions = int.parse(snapshot.value.toString());
        }
        
        // Increment the contributions count
        currentContributions += 1;

        // Update the contributions count in Firebase
        await contributionsRef.set(currentContributions);
        print("Contributions updated to $currentContributions.");
    } catch (e) {
        print("Error updating contributions: $e");
        throw Exception("Failed to update contributions.");
    }
}


  Future<void> updateUserPfpAttribute(String uid, int pfp) async {
    await _dbRef.child('users/$uid/pfp').set(pfp);
  }

  Future<int?> getPfpAttribute(String uid) async {
    try {
      DataSnapshot snapshot = await _dbRef.child('users/$uid/pfp').get();
      if (snapshot.exists && snapshot.value != null) {
        return int.tryParse(snapshot.value.toString());
      } else {
        print("No pfp attribute found for user $uid.");
      }
    } catch (e) {
      print("Error fetching pfp attribute for user $uid: $e");
    }
    return null;
  }
}

