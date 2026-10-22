bool isValidEmail(String value) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
}

class PasswordCheck {
  const PasswordCheck({
    required this.longEnough,
    required this.hasNumber,
    required this.hasSymbol,
    required this.avoidsName,
  });

  final bool longEnough;
  final bool hasNumber;
  final bool hasSymbol;
  final bool avoidsName;

  bool get isStrong => longEnough && hasNumber && hasSymbol && avoidsName;
}

PasswordCheck checkPassword(String password, {String name = ''}) {
  final lowerPassword = password.toLowerCase();
  final parts = name
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((part) => part.length >= 3);
  final usesName = parts.any(lowerPassword.contains);

  return PasswordCheck(
    longEnough: password.length >= 8,
    hasNumber: RegExp(r'\d').hasMatch(password),
    hasSymbol: RegExp(r'[^A-Za-z0-9]').hasMatch(password),
    avoidsName: password.isEmpty || !usesName,
  );
}
