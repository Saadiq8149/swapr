# Keep Razorpay classes
-keep class com.razorpay.** { *; }

# Ignore missing Google Pay classes
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**

# Keep general classes used by Razorpay
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep required Razorpay JSON models
-keepclassmembers class com.razorpay.** {
    public private protected *;
}

# Keep native methods
-keepclasseswithmembers class * {
    native <methods>;
}-dontwarn proguard.annotation.**
-keep class proguard.annotation.** { *; }
