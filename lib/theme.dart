import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4281295500),
      surfaceTint: Color(4281295500),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4291749375),
      onPrimaryContainer: Color(4278197555),
      secondary: Color(4283523183),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292207863),
      onSecondaryContainer: Color(4279115050),
      tertiary: Color(4285028474),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4293909503),
      onTertiaryContainer: Color(4280489267),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294441471),
      onSurface: Color(4279770144),
      onSurfaceVariant: Color(4282533710),
      outline: Color(4285691775),
      outlineVariant: Color(4290955215),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281151797),
      inversePrimary: Color(4288400379),
      primaryFixed: Color(4291749375),
      onPrimaryFixed: Color(4278197555),
      primaryFixedDim: Color(4288400379),
      onPrimaryFixedVariant: Color(4279192179),
      secondaryFixed: Color(4292207863),
      onSecondaryFixed: Color(4279115050),
      secondaryFixedDim: Color(4290365658),
      onSecondaryFixedVariant: Color(4282009687),
      tertiaryFixed: Color(4293909503),
      onTertiaryFixed: Color(4280489267),
      tertiaryFixedDim: Color(4292067302),
      onTertiaryFixedVariant: Color(4283449441),
      surfaceDim: Color(4292401888),
      surfaceBright: Color(4294441471),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294046713),
      surfaceContainer: Color(4293717747),
      surfaceContainerHigh: Color(4293322990),
      surfaceContainerHighest: Color(4292928232),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278601327),
      surfaceTint: Color(4281295500),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4282939556),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4281746515),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4284970630),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4283186269),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4286541201),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294441471),
      onSurface: Color(4279770144),
      onSurfaceVariant: Color(4282270538),
      outline: Color(4284112742),
      outlineVariant: Color(4285954946),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281151797),
      inversePrimary: Color(4288400379),
      primaryFixed: Color(4282939556),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4281163914),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4284970630),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283391341),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4286541201),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4284896631),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292401888),
      surfaceBright: Color(4294441471),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294046713),
      surfaceContainer: Color(4293717747),
      surfaceContainerHigh: Color(4293322990),
      surfaceContainerHighest: Color(4292928232),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278199357),
      surfaceTint: Color(4281295500),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4278601327),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4279575345),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4281746515),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4280949818),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283186269),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294441471),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280230954),
      outline: Color(4282270538),
      outlineVariant: Color(4282270538),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281151797),
      inversePrimary: Color(4292931071),
      primaryFixed: Color(4278601327),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278202190),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4281746515),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280299068),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283186269),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4281673285),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292401888),
      surfaceBright: Color(4294441471),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294046713),
      surfaceContainer: Color(4293717747),
      surfaceContainerHigh: Color(4293322990),
      surfaceContainerHighest: Color(4292928232),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4288400379),
      surfaceTint: Color(4288400379),
      onPrimary: Color(4278203219),
      primaryContainer: Color(4279192179),
      onPrimaryContainer: Color(4291749375),
      secondary: Color(4290365658),
      onSecondary: Color(4280562240),
      secondaryContainer: Color(4282009687),
      onSecondaryContainer: Color(4292207863),
      tertiary: Color(4292067302),
      onTertiary: Color(4281936457),
      tertiaryContainer: Color(4283449441),
      onTertiaryContainer: Color(4293909503),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279243800),
      onSurface: Color(4292928232),
      onSurfaceVariant: Color(4290955215),
      outline: Color(4287402392),
      outlineVariant: Color(4282533710),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928232),
      inversePrimary: Color(4281295500),
      primaryFixed: Color(4291749375),
      onPrimaryFixed: Color(4278197555),
      primaryFixedDim: Color(4288400379),
      onPrimaryFixedVariant: Color(4279192179),
      secondaryFixed: Color(4292207863),
      onSecondaryFixed: Color(4279115050),
      secondaryFixedDim: Color(4290365658),
      onSecondaryFixedVariant: Color(4282009687),
      tertiaryFixed: Color(4293909503),
      onTertiaryFixed: Color(4280489267),
      tertiaryFixedDim: Color(4292067302),
      onTertiaryFixedVariant: Color(4283449441),
      surfaceDim: Color(4279243800),
      surfaceBright: Color(4281743678),
      surfaceContainerLowest: Color(4278914834),
      surfaceContainerLow: Color(4279770144),
      surfaceContainer: Color(4280033316),
      surfaceContainerHigh: Color(4280756783),
      surfaceContainerHighest: Color(4281480505),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4288729087),
      surfaceTint: Color(4288400379),
      onPrimary: Color(4278196267),
      primaryContainer: Color(4284847554),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4290628830),
      onSecondary: Color(4278720293),
      secondaryContainer: Color(4286812835),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4292396011),
      onTertiary: Color(4280094509),
      tertiaryContainer: Color(4288448942),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279243800),
      onSurface: Color(4294638335),
      onSurfaceVariant: Color(4291218387),
      outline: Color(4288586667),
      outlineVariant: Color(4286481291),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928232),
      inversePrimary: Color(4279323508),
      primaryFixed: Color(4291749375),
      onPrimaryFixed: Color(4278194723),
      primaryFixedDim: Color(4288400379),
      onPrimaryFixedVariant: Color(4278204764),
      secondaryFixed: Color(4292207863),
      onSecondaryFixed: Color(4278456863),
      secondaryFixedDim: Color(4290365658),
      onSecondaryFixedVariant: Color(4280891206),
      tertiaryFixed: Color(4293909503),
      onTertiaryFixed: Color(4279765544),
      tertiaryFixedDim: Color(4292067302),
      onTertiaryFixedVariant: Color(4282331215),
      surfaceDim: Color(4279243800),
      surfaceBright: Color(4281743678),
      surfaceContainerLowest: Color(4278914834),
      surfaceContainerLow: Color(4279770144),
      surfaceContainer: Color(4280033316),
      surfaceContainerHigh: Color(4280756783),
      surfaceContainerHighest: Color(4281480505),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294638335),
      surfaceTint: Color(4288400379),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4288729087),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294638335),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4290628830),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965756),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4292396011),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279243800),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294638335),
      outline: Color(4291218387),
      outlineVariant: Color(4291218387),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928232),
      inversePrimary: Color(4278201417),
      primaryFixed: Color(4292274687),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4288729087),
      onPrimaryFixedVariant: Color(4278196267),
      secondaryFixed: Color(4292471035),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4290628830),
      onSecondaryFixedVariant: Color(4278720293),
      tertiaryFixed: Color(4294107647),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4292396011),
      onTertiaryFixedVariant: Color(4280094509),
      surfaceDim: Color(4279243800),
      surfaceBright: Color(4281743678),
      surfaceContainerLowest: Color(4278914834),
      surfaceContainerLow: Color(4279770144),
      surfaceContainer: Color(4280033316),
      surfaceContainerHigh: Color(4280756783),
      surfaceContainerHighest: Color(4281480505),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
