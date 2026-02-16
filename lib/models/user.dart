/// User model - Matches User.kt from the Android project.
class User {
  final String? id;
  final String? email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? location;
  final String? avatarUrl;
  final String preferences;

  const User({
    this.id,
    this.email,
    this.role = 'user',
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.location,
    this.avatarUrl,
    this.preferences = '{}',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'user',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      location: json['location'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferences: json['preferences'] as String? ?? '{}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth,
      'location': location,
      'avatar_url': avatarUrl,
      'preferences': preferences,
    };
  }
}
