import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in aborted');
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(
            loginResult.accessToken?.tokenString ?? '',
          );

      return await _firebaseAuth.signInWithCredential(facebookAuthCredential);
    } else {
      throw Exception('Facebook sign in aborted: ${result.status}');
    }
  }

  Future<UserCredential> signInWithFacebookIos() async {
    // Check if the user has authorized the app to use the tracking data (only for iOS)
    TrackingStatus? status;
    if (Platform.isIOS) {
      status = await AppTrackingTransparency.trackingAuthorizationStatus;
    }

    // Trigger the sign-in flow
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    final result = await FacebookAuth.instance.login(
      loginTracking:
          status == TrackingStatus.authorized
              ? LoginTracking.enabled
              : LoginTracking.limited,
      loginBehavior: LoginBehavior.nativeWithFallback,
      permissions: [
        'email',
        if (status == TrackingStatus.authorized) 'public_profile',
      ],
      nonce: nonce,
    );

    // Create a credential from the access token
    OAuthCredential credential = OAuthCredential(
      providerId: 'facebook.com',
      signInMethod: 'oauth',
      idToken: result.accessToken!.tokenString,
      rawNonce: rawNonce,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithGoogleWeb() async {
    GoogleAuthProvider authProvider = GoogleAuthProvider();
    final UserCredential userCredential = await _firebaseAuth.signInWithPopup(
      authProvider,
    );

    return userCredential;
  }

  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  // NEW: Email/Password Sign Up
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Optional: Set display name immediately
      await userCredential.user?.updateDisplayName(email.split('@').first);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      }
      throw Exception(e.message ?? 'Unknown sign up error.');
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up: $e');
    }
  }

  // NEW: Email/Password Sign In
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
      throw Exception(e.message ?? 'Unknown sign in error.');
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in: $e');
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.

    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: Platform.isIOS ? nonce : null,
      webAuthenticationOptions:
          Platform.isIOS
              ? null
              : WebAuthenticationOptions(
                clientId: 'com.ikhwan.moodjournalapp.login',
                redirectUri: Uri.parse(
                  'https://berry-wool-breakfast.glitch.me/callbacks/sign_in_with_apple',
                ),
              ),
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: Platform.isIOS ? rawNonce : null,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }
}
