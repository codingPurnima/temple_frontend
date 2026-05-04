class Session {
  static String? role;

  static bool get isAdmin =>
      role == "ADMIN" || role == "SUPER_ADMIN";

  static bool get isSuperAdmin =>
      role == "SUPER_ADMIN";

  static bool get isPremiumUser =>
      role == "PREMIUM_USER";
}