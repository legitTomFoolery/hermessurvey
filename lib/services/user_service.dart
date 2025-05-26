import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsecsurvey/core/environment_config.dart';

class UserService {
  static final _envConfig = EnvironmentConfig();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the users collection reference with environment configuration
  static CollectionReference get _usersCollection =>
      _firestore.collection(_envConfig.getCollectionName('users'));

  /// Check if a user exists in the users collection
  static Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      // Error checking if user exists: $e
      return false;
    }
  }

  /// Create a new user document with default isAdmin value
  static Future<void> createUser(String uid) async {
    try {
      await _usersCollection.doc(uid).set({
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Error creating user: $e
      rethrow;
    }
  }

  /// Check if the current user is an admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      DocumentSnapshot doc = await _usersCollection.doc(user.uid).get();

      if (!doc.exists) {
        // Create the user if they don't exist
        await createUser(user.uid);
        return false;
      }

      return doc.get('isAdmin') == true;
    } catch (e) {
      // Error checking if user is admin: $e
      return false;
    }
  }

  /// Check if a specific user is an admin
  static Future<bool> isUserAdmin(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();

      if (!doc.exists) {
        // Create the user if they don't exist
        await createUser(uid);
        return false;
      }

      return doc.get('isAdmin') == true;
    } catch (e) {
      // Error checking if user is admin: $e
      return false;
    }
  }
}
