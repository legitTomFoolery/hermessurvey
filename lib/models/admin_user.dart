import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isAdmin;
  final DateTime? createdAt;

  AdminUser({
    required this.uid,
    this.email,
    this.displayName,
    required this.isAdmin,
    this.createdAt,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return AdminUser(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      isAdmin: data['isAdmin'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
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
    };
  }

  AdminUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return AdminUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
