class UserDetails {
  final String uid;
  final String displayName;
  // add any other fields you store under players/UID

  UserDetails({
    required this.uid,
    required this.displayName,
  });

  factory UserDetails.fromMap(Map<String, dynamic> m) {
    return UserDetails(
      uid: m['uid'] as String,
      displayName: m['displayName'] as String,
    );
  }
}
