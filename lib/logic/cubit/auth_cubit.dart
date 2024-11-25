import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit() : super(AuthInitial());

  void resetState() {
    emit(AuthInitial());
  }

  Future<void> createAccountAndLinkItWithGoogleAccount(
      String email,
      String password,
      GoogleSignInAccount googleUser,
      OAuthCredential credential) async {
    emit(AuthLoading());

    try {
      await _auth.createUserWithEmailAndPassword(
        email: googleUser.email,
        password: password,
      );
      await _auth.currentUser!.linkWithCredential(credential);
      await _auth.currentUser!.updateDisplayName(googleUser.displayName);
      await _auth.currentUser!.updatePhotoURL(googleUser.photoUrl);
      emit(UserSingupAndLinkedWithGoogle());
    } catch (e) {
      emit(AuthError(
          'An error occurred while creating your account. Please try again.'));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(ResetPasswordSent());
    } catch (e) {
      emit(AuthError(
          'Unable to send password reset email. Please verify your email address.'));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user!.emailVerified) {
        emit(UserSignIn());
      } else {
        await _auth.signOut();
        emit(UserNotVerified());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        emit(AuthError('Invalid email/password, please try again.'));
      } else {
        emit(AuthError('An error occurred. Please try again.'));
      }
    } catch (e) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(AuthError('Google Sign In was cancelled'));
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      if (authResult.additionalUserInfo!.isNewUser) {
        await _auth.currentUser!.delete();
        emit(IsNewUser(googleUser: googleUser, credential: credential));
      } else {
        emit(UserSignIn());
      }
    } catch (e) {
      emit(AuthError('Unable to sign in with Google. Please try again.'));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await _auth.signOut();
    emit(UserSignedOut());
  }

  Future<void> signUpWithEmail(
      String name, String email, String password) async {
    try {
      // First check if email exists
      var methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        // Try to sign in to check verification status
        try {
          UserCredential userCredential =
              await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (userCredential.user!.emailVerified) {
            await _auth.signOut();
            emit(AuthError('Email already in use.'));
          } else {
            await _auth.signOut();
            emit(ExistingEmailNotVerified());
          }
        } on FirebaseAuthException {
          // If sign in fails, assume email exists but is verified
          // (since unverified emails are eventually deleted by Firebase)
          emit(AuthError('Email already in use.'));
        }
        return;
      }

      // If we get here, email doesn't exist, proceed with new registration
      emit(AuthLoading());
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _auth.currentUser!.updateDisplayName(name);
      await _auth.currentUser!.sendEmailVerification();
      await _auth.signOut();
      emit(UserSingupButNotVerified());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emit(AuthError('Email already in use.'));
      } else {
        emit(AuthError(
            'An error occurred while creating your account. Please try again.'));
      }
    } catch (e) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  Future<bool> checkUserAccountExists() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();

      user = _auth.currentUser;
      if (user == null) return false;

      if (!user.providerData.any((info) => info.providerId == 'google.com') &&
          !user.emailVerified) {
        return false;
      }

      String? token = await user.getIdToken(true);
      return token != null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-token-expired' ||
          e.code == 'user-not-found' ||
          e.code == 'user-disabled') {
        return false;
      }
      rethrow;
    } catch (e) {
      print('Error checking user account: $e');
      return false;
    }
  }
}
