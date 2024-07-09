import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should sign in anonymously', () async {
    // Creating a mock instance of FirebaseAuth.
    final auth = MockFirebaseAuth();
    final result = await auth.signInAnonymously();
    final user = result.user;

    expect(user, isNotNull);
    expect(user!.isAnonymous, true);
  });

  test('sign in with email and password', () async {
    final auth = MockFirebaseAuth(
        mockUser: MockUser(email: 'test@example.com', uid: '12345'));
    final result = await auth.signInWithEmailAndPassword(
        email: 'test@example.com', password: 'password');
    final user = result.user;

    expect(user, isNotNull);
    expect(user!.email, equals('test@example.com'));
  });

  test('should sign up with email and password', () async {
    // Creating a mock instance of FirebaseAuth.
    final auth = MockFirebaseAuth(
        signedIn: false,
        mockUser: MockUser(email: 'newuser@example.com', uid: '1'));

    // Assuming signUpWithEmailAndPassword is a method you would implement that calls
    // FirebaseAuth's createUserWithEmailAndPassword method under the hood.
    final result = await auth.createUserWithEmailAndPassword(
        email: 'newuser@example.com', password: 'newPassword');
    final user = result.user;

    // Checking the user details after signing up
    expect(user, isNotNull);
    expect(user!.email, equals('newuser@example.com'));
    
  });
}
