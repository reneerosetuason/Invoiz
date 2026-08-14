class User {
  final int id;
  final String lastName;
  final String firstName;
  final String? middleInitial;
  final String? sex;
  final String email;
  final String? phone;
  final String? birthday;
  final int? age;
  final String? role;
  final String? approvalStatus;
  final String? province;
  final String? municipality;
  final String? barangay;
  final String? addressLine;
  final String? idImage;

  User({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.middleInitial,
    this.sex,
    required this.email,
    this.phone,
    this.birthday,
    this.age,
    this.role,
    this.approvalStatus,
    this.province,
    this.municipality,
    this.barangay,
    this.addressLine,
    this.idImage,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        lastName: json['last_name'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        middleInitial: json['middle_initial'] as String?,
        sex: json['sex'] as String?,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        birthday: json['birthday'] as String?,
        age: json['age'] as int?,
        role: json['role'] as String?,
        approvalStatus: json['approval_status'] as String?,
        province: json['province'] as String?,
        municipality: json['municipality'] as String?,
        barangay: json['barangay'] as String?,
        addressLine: json['address_line'] as String?,
        idImage: json['id_image'] as String?,
      );

  String get fullName =>
      '${firstName} ${middleInitial != null && middleInitial!.isNotEmpty ? middleInitial! + '.' : ''} $lastName';
}