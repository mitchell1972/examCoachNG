# Flutter ProGuard rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Billing
-keep class com.android.vending.billing.** { *; }
-keep class com.android.billingclient.** { *; }

# Firebase (if using)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep our app's classes
-keep class com.examcoachng.app.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# For debugging (remove in production)
-keepattributes SourceFile,LineNumberTable
