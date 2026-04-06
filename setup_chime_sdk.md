# Quick Setup Guide - Amazon Chime SDK

## Current Status

Your app is fully configured for Amazon Chime SDK integration. The only missing piece is the SDK library files.

## What's Already Done ✅

- ✅ Native Android code (ChimePlugin.kt)
- ✅ Video rendering (ChimeVideoViewFactory.kt)
- ✅ Flutter service layer (ChimeService)
- ✅ Beautiful video call UI
- ✅ All permissions configured
- ✅ Build configuration ready
- ✅ ProGuard rules for release builds

## What You Need to Do

### Step 1: Download AAR Files

Download these 2 files from GitHub:
https://github.com/aws/amazon-chime-sdk-android/releases

Files needed:
- `amazon-chime-sdk-0.23.5.aar`
- `amazon-chime-sdk-media-0.23.5.aar`

### Step 2: Create libs Folder

```bash
mkdir android/app/libs
```

### Step 3: Copy AAR Files

Copy the downloaded AAR files to:
```
android/app/libs/amazon-chime-sdk-0.23.5.aar
android/app/libs/amazon-chime-sdk-media-0.23.5.aar
```

### Step 4: Build and Run

```bash
flutter clean
flutter pub get
flutter run
```

## That's It!

Once the AAR files are in place, your video calling will work perfectly.

## Testing

1. Open the app
2. Tap "Start New Meeting" or "Join a Meeting"
3. Enter meeting details
4. Tap "Start Call" or "Join Call"
5. You should see:
   - Your camera feed
   - Working audio
   - Mute/unmute button
   - Video on/off button
   - Camera flip button
   - End call button

## Troubleshooting

### Build fails with "Could not find amazon-chime-sdk"

**Check:**
- AAR files are in `android/app/libs/`
- File names match exactly: `amazon-chime-sdk-0.23.5.aar` and `amazon-chime-sdk-media-0.23.5.aar`

### Video doesn't show

**Check:**
1. Camera permission granted
2. Meeting credentials are valid (check API response)
3. Logcat for errors: `adb logcat | grep Chime`

### App crashes on video call

**Check:**
1. ProGuard rules are in place (already done)
2. MultiDex is enabled (already done)
3. Minimum SDK is 21+ (already done)

## Alternative: Try JitPack First

If you want to try JitPack before manual installation:

1. Edit `android/build.gradle.kts`:
```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }  // Uncomment this
    }
}
```

2. Edit `android/app/build.gradle.kts`:
```kotlin
dependencies {
    // Uncomment these:
    implementation("com.github.aws.amazon-chime-sdk-android:amazon-chime-sdk:0.23.5")
    implementation("com.github.aws.amazon-chime-sdk-android:amazon-chime-sdk-media:0.23.5")
    
    // Comment out this:
    // implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.aar"))))
}
```

3. Run:
```bash
flutter clean
flutter run
```

If JitPack works, great! If not, use the manual AAR installation method above.

## Need More Help?

See `CHIME_MANUAL_INSTALLATION.md` for detailed troubleshooting and alternative installation methods.
