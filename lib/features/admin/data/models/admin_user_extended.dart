import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnhancedAdminUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isAdmin;
  final DateTime? createdAt;
  final DateTime? lastSignInTime;
  final bool emailVerified;
  final String? photoURL;
  final bool isFromCustomCollection;
  final bool isFromFirebaseAuth;

  EnhancedAdminUser({
    required this.uid,
    this.email,
    this.displayName,
    required this.isAdmin,
    this.createdAt,
    this.lastSignInTime,
    this.emailVerified = false,
    this.photoURL,
    this.isFromCustomCollection = false,
    this.isFromFirebaseAuth = false,
  });

  // Create from Firebase Auth User
  factory EnhancedAdminUser.fromFirebaseAuth(User user,
      {bool isAdmin = false}) {
    return EnhancedAdminUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      isAdmin: isAdmin,
      createdAt: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
      emailVerified: user.emailVerified,
      photoURL: user.photoURL,
      isFromFirebaseAuth: true,
    );
  }

  // Create from Firestore document
  factory EnhancedAdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return EnhancedAdminUser(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      isAdmin: data['isAdmin'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      lastSignInTime: data['lastSignInTime'] != null
          ? (data['lastSignInTime'] as Timestamp).toDate()
          : null,
      emailVerified: data['emailVerified'] as bool? ?? false,
      photoURL: data['photoURL'] as String?,
      isFromCustomCollection: true,
    );
  }

  // Merge Firebase Auth user with custom collection data
  factory EnhancedAdminUser.merge(User authUser, DocumentSnapshot? customDoc) {
    final customData = customDoc?.data() as Map<String, dynamic>? ?? {};

    return EnhancedAdminUser(
      uid: authUser.uid,
      email: authUser.email ?? customData['email'] as String?,
      displayName: authUser.displayName ?? customData['displayName'] as String?,
      isAdmin: customData['isAdmin'] as bool? ?? false,
      createdAt: authUser.metadata.creationTime,
      lastSignInTime: authUser.metadata.lastSignInTime,
      emailVerified: authUser.emailVerified,
      photoURL: authUser.photoURL ?? customData['photoURL'] as String?,
      isFromCustomCollection: customDoc?.exists ?? false,
      isFromFirebaseAuth: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'isAdmin': isAdmin,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'lastSignInTime':
          lastSignInTime != null ? Timestamp.fromDate(lastSignInTime!) : null,
      'emailVerified': emailVerified,
      'photoURL': photoURL,
    };
  }

  EnhancedAdminUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? lastSignInTime,
    bool? emailVerified,
    String? photoURL,
    bool? isFromCustomCollection,
    bool? isFromFirebaseAuth,
  }) {
    return EnhancedAdminUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      emailVerified: emailVerified ?? this.emailVerified,
      photoURL: photoURL ?? this.photoURL,
      isFromCustomCollection:
          isFromCustomCollection ?? this.isFromCustomCollection,
      isFromFirebaseAuth: isFromFirebaseAuth ?? this.isFromFirebaseAuth,
    );
  }

  String get statusText {
    if (isFromFirebaseAuth && isFromCustomCollection) {
      return 'Complete Profile';
    } else if (isFromFirebaseAuth) {
      return 'Auth Only';
    } else if (isFromCustomCollection) {
      return 'Custom Only';
    }
    return 'Unknown';
  }
}
