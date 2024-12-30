class UserPreferences {
  final String uid;
  final String currency;
  final bool useSystemTheme;
  final bool isDarkMode;
  final bool showCents;
  final bool enableNotifications;

  UserPreferences({
    required this.uid,
    required this.currency,
    required this.useSystemTheme,
    required this.isDarkMode,
    required this.showCents,
    required this.enableNotifications,
  });

  UserPreferences copyWith({
    String? uid,
    String? currency,
    bool? useSystemTheme,
    bool? isDarkMode,
    bool? showCents,
    bool? enableNotifications,
  }) {
    return UserPreferences(
      uid: uid ?? this.uid,
      currency: currency ?? this.currency,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      showCents: showCents ?? this.showCents,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'currency': currency,
      'useSystemTheme': useSystemTheme,
      'isDarkMode': isDarkMode,
      'showCents': showCents,
      'enableNotifications': enableNotifications,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      uid: map['uid'] ?? '',
      currency: map['currency'] ?? 'USD',
      useSystemTheme: map['useSystemTheme'] ?? true,
      isDarkMode: map['isDarkMode'] ?? false,
      showCents: map['showCents'] ?? true,
      enableNotifications: map['enableNotifications'] ?? true,
    );
  }
}
