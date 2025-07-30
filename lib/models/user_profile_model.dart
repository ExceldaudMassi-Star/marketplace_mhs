// PERBAIKAN UNTUK: lib/models/user_profile_model.dart

class UserProfile {
  final String uid;
  final String email;
  String fullName;
  String phoneNumber;
  String? gender;
  String? address;
  String? campus;
  String? bio;
  String? photoURL;
  List<String> favorites; // DITAMBAHKAN

  UserProfile({
    required this.uid,
    required this.email,
    this.fullName = '',
    this.phoneNumber = '',
    this.gender,
    this.address,
    this.campus,
    this.bio,
    this.photoURL,
    this.favorites = const [], // DITAMBAHKAN
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      gender: map['gender'],
      address: map['address'],
      campus: map['campus'],
      bio: map['bio'],
      photoURL: map['photoURL'],
      // Mengambil daftar favorit dari Firestore
      favorites: List<String>.from(map['favorites'] ?? []), // DITAMBAHKAN
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'address': address,
      'campus': campus,
      'bio': bio,
      'photoURL': photoURL,
      'favorites': favorites, // DITAMBAHKAN
    };
  }
}
