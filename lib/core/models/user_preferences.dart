class UserPreferences {
  final String uid;
  final String currency;
  final bool useSystemTheme;
  final bool isDarkMode;
  final bool showCents;
  final bool enableNotifications;
  final String decimalSeparatorPreference; // 'device', 'dot', 'comma'
  final String
      thousandsSeparatorPreference; // 'device', 'dot', 'comma', 'space', 'none'

  UserPreferences({
    required this.uid,
    required this.currency,
    required this.useSystemTheme,
    required this.isDarkMode,
    required this.showCents,
    required this.enableNotifications,
    this.decimalSeparatorPreference = 'device', // Default to device setting
    this.thousandsSeparatorPreference = 'device', // Default to device setting
  });

  UserPreferences copyWith({
    String? uid,
    String? currency,
    bool? useSystemTheme,
    bool? isDarkMode,
    bool? showCents,
    bool? enableNotifications,
    String? decimalSeparatorPreference,
    String? thousandsSeparatorPreference,
  }) {
    return UserPreferences(
      uid: uid ?? this.uid,
      currency: currency ?? this.currency,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      showCents: showCents ?? this.showCents,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      decimalSeparatorPreference:
          decimalSeparatorPreference ?? this.decimalSeparatorPreference,
      thousandsSeparatorPreference:
          thousandsSeparatorPreference ?? this.thousandsSeparatorPreference,
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
      'decimalSeparatorPreference': decimalSeparatorPreference,
      'thousandsSeparatorPreference': thousandsSeparatorPreference,
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
      decimalSeparatorPreference: map['decimalSeparatorPreference'] ?? 'device',
      thousandsSeparatorPreference:
          map['thousandsSeparatorPreference'] ?? 'device',
    );
  }

  String get decimalSeparatorDescription {
    switch (decimalSeparatorPreference) {
      case 'dot':
        return 'Dot (.)';
      case 'comma':
        return 'Comma (,)';
      case 'device':
      default:
        return 'Device Default';
    }
  }

  String get thousandsSeparatorDescription {
    switch (thousandsSeparatorPreference) {
      case 'dot':
        return 'Dot (.)';
      case 'comma':
        return 'Comma (,)';
      case 'space':
        return 'Space ( )';
      case 'none':
        return 'None';
      case 'device':
      default:
        return 'Device Default';
    }
  }
}
