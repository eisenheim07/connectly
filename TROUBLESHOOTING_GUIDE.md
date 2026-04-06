# Amazon Chime SDK - Troubleshooting Guide

## Platform-Specific Issues Encountered

### Issue 1: Native Library Loading Failure (Android)

**Problem:**
```
E/AudioClientFactory: Unable to load native media libraries: dlopen failed: library "libc++_shared.so" not found
java.lang.UnsatisfiedLinkError: No implementation found for int com.xodee.client.audio.audioclient.AudioClient.initNative
```

**Root Cause:**
- The AAR files downloaded manually didn't include native `.so` libraries
- Android couldn't find the required C++ shared libraries at runtime
- The native libraries weren't being packaged into the APK

**Debugging Process:**
1. **Checked logcat output:**
   ```bash
   adb logcat | grep -i "chime\|native\|\.so"
   ```
   Found: `dlopen failed: library "libc++_shared.so" not found`

2. **Inspected AAR contents:**
   ```bash
   unzip -l amazon-chime-sdk-media.aar | grep ".so"
   ```
   Found: Native libraries were present in `jni/` folder

3. **Verified APK contents:**
   ```bash
   unzip -l app-debug.apk | grep "lib/.*\.so"
   ```
   Found: Libraries weren't being packaged

4. **Checked build configuration:**
   - Missing `jniLibs` source set configuration
   - Incorrect packaging options

**Solution:**
Switched from manual AAR files to Maven dependency:
```kotlin
dependencies {
    implementation("software.aws.chimesdk:amazon-chime-sdk:0.25.2")
    implementation("software.aws.chimesdk:amazon-chime-sdk-media:0.25.2")
}
```

**What Changed:**
- **Platform Code (Android):**
  - Removed manual library loading in `MainActivity.kt`
  - Removed `jniLibs` folder
  - Simplified `build.gradle.kts` configuration
  
- **Flutter Code:**
  - No changes required
  - ChimeService continued to work as-is

**Logs Used:**
- `adb logcat` - System logs
- `flutter run -v` - Verbose Flutter output
- Gradle build logs with `--info` flag

**Key Learnings:**
- Always use official Maven dependencies when available
- Manual AAR extraction is error-prone
- Native library packaging requires proper Gradle configuration

---

### Issue 2: Video View Not Rendering

**Problem:**
- Local video showed black screen
- Remote video not displaying when second user joined

**Root Cause:**
- Only one `ChimeVideoView` was being created
- Both local and remote tiles tried to bind to the same view
- Video view factory wasn't tracking multiple views

**Debugging Process:**
1. **Checked native logs:**
   ```
   D/ChimePlugin: Video tile added: 1, isLocal: true
   W/ChimePlugin: No video view available for tile 1
   ```

2. **Inspected video view factory:**
   - Found: Only storing single `currentVideoView`
   - Issue: No distinction between local/remote views

3. **Reviewed Flutter widget tree:**
   - Only one `ChimeVideoView` widget in UI

**Solution:**
1. Updated `ChimeVideoViewFactory` to track multiple views:
```kotlin
private val videoViews = mutableMapOf<Int, ChimeVideoView>()

fun getLocalVideoView(): ChimeVideoView? = 
    videoViews.values.firstOrNull { it.isLocalVideo }
    
fun getRemoteVideoView(): ChimeVideoView? = 
    videoViews.values.firstOrNull { !it.isLocalVideo }
```

2. Updated UI to show both views:
```dart
Stack(
  children: [
    // Remote video (full screen)
    Positioned.fill(
      child: ChimeVideoView(isLocalVideo: false),
    ),
    // Local video (PIP)
    Positioned(
      top: 80, right: 16,
      child: ChimeVideoView(isLocalVideo: true),
    ),
  ],
)
```

**What Changed:**
- **Platform Code:**
  - `ChimeVideoViewFactory.kt` - Track multiple views
  - `ChimePlugin.kt` - Bind tiles to correct view based on `isLocalTile`
  
- **Flutter Code:**
  - `video_call_screen.dart` - Added second video view widget

---

## Common Issues & Solutions

### Issue: App crashes on emulator but works on device

**Cause:** Emulator uses x86_64 architecture, device uses ARM

**Solution:** Ensure all architectures are included:
```kotlin
ndk {
    abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64"))
}
```

### Issue: Permission denied errors

**Check:**
1. Permissions in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

2. Runtime permission handling in Flutter:
```dart
await Permission.camera.request();
await Permission.microphone.request();
```

### Issue: Meeting fails to join

**Debug Steps:**
1. Check event logs in app
2. Verify meeting ID format
3. Check network connectivity
4. Review MediaPlacement URLs
5. Verify attendee token is valid

**Logs to check:**
```bash
# Flutter logs
flutter logs

# Android logs
adb logcat -s ChimePlugin:D flutter:I

# Filter for errors
adb logcat | grep -E "ERROR|FATAL|ChimePlugin"
```

---

## Debugging Tools

### 1. Event Log Screen
Access via video call screen → Event Log button
- Shows last 50 Chime events
- Structured logs with timestamps
- Error classification
- Export capability

### 2. Network Resilience Monitor
- Connection state tracking
- Reconnection attempts
- Exponential backoff visualization
- Stale session detection

### 3. Logcat Filters
```bash
# Chime-specific logs
adb logcat -s ChimePlugin:D

# Native library logs
adb logcat | grep -i "\.so\|native\|jni"

# Video tile logs
adb logcat | grep -i "video.*tile"

# Network logs
adb logcat | grep -i "network\|connection"
```

### 4. Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```
- Network inspector
- Logging view
- Performance profiler

---

## Performance Optimization

### Reduce APK Size
```kotlin
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### Optimize Video Quality
```kotlin
// In ChimePlugin.kt
audioVideo?.startLocalVideo(
    VideoConfiguration(
        maxBitRateKbps = 1200,
        maxResolution = VideoResolution.VideoResolution720p
    )
)
```

---

## Production Checklist

- [ ] All permissions properly requested
- [ ] Error handling for all API calls
- [ ] Network resilience implemented
- [ ] Event logging enabled
- [ ] Crash reporting integrated
- [ ] Release build tested
- [ ] ProGuard rules configured
- [ ] App icons set
- [ ] Bundle ID configured
- [ ] Privacy policy added
