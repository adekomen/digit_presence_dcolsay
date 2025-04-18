class User {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String role;
  final String qrCode;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.role,
    required this.qrCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['utilisateur_id'] ?? json['id'],
      firstname: json['prenom_utilisateur'] ?? json['firstname'] ?? '',
      lastname: json['nom_utilisateur'] ?? json['lastname'] ?? '',
      email: json['email_utilisateur'] ?? json['email'] ?? '',
      phone: json['telephone_utilisateur'] ?? json['phone'] ?? '',
      role: json['role_nom'] ?? json['role'] ?? 'User',
      qrCode: json['qr_code_utilisateur'] ?? json['qr_code'] ?? '',
    );
  }

  get createdAt => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'role': role,
      'qr_code': qrCode,
    };
  }
}
