enum UserRole { operatore, amministratore }

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.initials,
  });

  final String id;
  final String username;
  final String displayName;
  final UserRole role;
  final String initials;

  String get roleLabel => switch (role) {
        UserRole.operatore => 'Operatore',
        UserRole.amministratore => 'Amministratore',
      };
}
