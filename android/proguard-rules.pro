# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Prevent obfuscation of models
-keep class com.cbrf.fundi.models.** { *; }
