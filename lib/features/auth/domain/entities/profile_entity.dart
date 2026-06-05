// Tanggung jawab: Entity Domain untuk data profil pengguna.
// Merepresentasikan tabel `profiles` di Supabase.
// Entity ini TIDAK bergantung pada library apapun — murni Dart.

class ProfileEntity {
  final String id;           // UUID dari Supabase Auth
  final String fullName;
  final String? phoneNumber;
  final int miPoints;        // Poin loyalitas Mi Points

  const ProfileEntity({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    required this.miPoints,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
