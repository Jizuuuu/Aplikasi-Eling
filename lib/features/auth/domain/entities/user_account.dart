class UserAccount {
  final String kodePengguna;
  final String namaPengguna;
  final String email;

  const UserAccount({
    required this.kodePengguna,
    required this.namaPengguna,
    required this.email,
  });

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      kodePengguna: map['KodePengguna'] as String,
      namaPengguna: map['NamaPengguna'] as String,
      email: map['Email'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'KodePengguna': kodePengguna,
      'NamaPengguna': namaPengguna,
      'Email': email,
    };
  }
}
