# Amazon Chime SDK
-keep class com.amazonaws.services.chime.sdk.** { *; }
-keep interface com.amazonaws.services.chime.sdk.** { *; }
-dontwarn com.amazonaws.services.chime.sdk.**

# WebRTC
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
