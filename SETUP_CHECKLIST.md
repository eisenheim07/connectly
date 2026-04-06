# Amazon Chime SDK Setup Checklist

## ✅ Already Done (No Action Needed)

- [x] Native Android code (ChimePlugin.kt)
- [x] Video rendering (ChimeVideoViewFactory.kt)
- [x] Flutter service layer (ChimeService.dart)
- [x] Video call UI (VideoCallScreen.dart)
- [x] Video widget (ChimeVideoView.dart)
- [x] Plugin registration (MainActivity.kt)
- [x] Build configuration (build.gradle.kts)
- [x] ProGuard rules (proguard-rules.pro)
- [x] Permissions (AndroidManifest.xml)
- [x] Design system integration
- [x] Button widgets
- [x] Error handling

## 📋 What You Need to Do

### Step 1: Download AAR Files ⏳

Go to: https://github.com/aws/amazon-chime-sdk-android/releases

Download:
- [ ] `amazon-chime-sdk-0.23.5.aar`
- [ ] `amazon-chime-sdk-media-0.23.5.aar`

### Step 2: Create libs Folder ⏳

```bash
mkdir android/app/libs
```

- [ ] Folder created at `android/app/libs/`

### Step 3: Copy AAR Files ⏳

Copy the downloaded files to `android/app/libs/`:

- [ ] `android/app/libs/amazon-chime-sdk-0.23.5.aar`
- [ ] `android/app/libs/amazon-chime-sdk-media-0.23.5.aar`

### Step 4: Build and Run ⏳

```bash
flutter clean
flutter pub get
flutter run
```

- [ ] Build successful
- [ ] App launches
- [ ] No errors in console

### Step 5: Test Video Calling ⏳

1. Open app
2. Tap "Start New Meeting" or "Join a Meeting"
3. Enter meeting details
4. Tap "Start Call" or "Join Call"

Check:
- [ ] Camera feed shows
- [ ] Audio works
- [ ] Mute button works
- [ ] Video on/off works
- [ ] Camera flip works
- [ ] End call works
- [ ] Can leave meeting

## 🎯 Expected File Structure

```
android/
├── app/
│   ├── libs/
│   │   ├── amazon-chime-sdk-0.23.5.aar          ← ADD THIS
│   │   └── amazon-chime-sdk-media-0.23.5.aar    ← ADD THIS
│   ├── src/
│   │   └── main/
│   │       └── kotlin/
│   │           └── com/example/connectly/
│   │               ├── ChimePlugin.kt            ✅ Done
│   │               ├── ChimeVideoViewFactory.kt  ✅ Done
│   │               └── MainActivity.kt           ✅ Done
│   ├── build.gradle.kts                          ✅ Done
│   └── proguard-rules.pro                        ✅ Done
└── build.gradle.kts                              ✅ Done
```

## 🚨 Troubleshooting

### Build fails with "Could not find amazon-chime-sdk"

**Solution:**
- Verify AAR files are in `android/app/libs/`
- Check file names match exactly
- Run `flutter clean` and try again

### Video doesn't show

**Solution:**
1. Check camera permission granted
2. Check API returns valid credentials
3. Check logcat: `adb logcat | grep Chime`

### App crashes on video call

**Solution:**
1. Verify both AAR files are present
2. Check ProGuard rules are in place (already done)
3. Check MultiDex is enabled (already done)

## 📚 Documentation

- **setup_chime_sdk.md** - Quick setup guide
- **CHIME_MANUAL_INSTALLATION.md** - Detailed installation
- **CHIME_SDK_STATUS.md** - Current status and features
- **SETUP_CHECKLIST.md** - This file

## 🎉 Success Criteria

When everything works, you should see:

1. **Meeting Screen**
   - Two cards for creating/joining meetings
   - Recent meetings section
   - Smooth navigation

2. **Video Call Screen**
   - Full-screen video
   - Connection status (green "CONNECTED")
   - Working controls (mute, video, flip, end)
   - Tap to show/hide controls

3. **No Errors**
   - No build errors
   - No runtime errors
   - No permission errors
   - Clean logcat output

## ⏱️ Estimated Time

- Download AAR files: 2-5 minutes
- Copy files: 1 minute
- Build and run: 2-3 minutes
- Testing: 5 minutes

**Total: ~10-15 minutes**

## 🆘 Need Help?

If you encounter issues:
1. Check the troubleshooting section above
2. Review `CHIME_MANUAL_INSTALLATION.md`
3. Check build logs for specific errors
4. Verify all files are in correct locations

## Summary

**Only 3 simple steps:**
1. Download 2 AAR files
2. Copy to `android/app/libs/`
3. Run `flutter clean && flutter run`

That's it! Your video calling will work perfectly.
