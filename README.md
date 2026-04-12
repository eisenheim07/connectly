# Connectly - Video Conferencing App

> **⚠️ SECURITY NOTICE**: The `lib/utils/app_constants.dart` file is NOT included in the Git repository as it contains sensitive API endpoints and configuration. You must create this file locally before running the project.

A Flutter-based video conferencing application powered by Amazon Chime SDK, designed for professional clarity and reliable communication.

## Overview

Connectly is a mobile video conferencing solution that enables high-quality video calls between agents and clients. Built with Flutter and integrated with Amazon Chime SDK, it provides a seamless video calling experience with robust network resilience and intuitive UI.

## Key Features

### Core Functionality
- **Start New Meeting**: Create instant video meetings as an agent
- **Join Meeting**: Join existing meetings using meeting details (JSON format)
- **Video Controls**: Toggle camera, mute/unmute audio, switch camera (front/back)
- **Real-time Video**: HD video streaming with local and remote video tiles
- **Meeting Re-join**: Rejoin recent meetings when both participants were present

### Network & Connectivity
- **Internet Monitoring**: Real-time connectivity detection with 3-second intervals
- **No Internet Bottom Sheet**: Modal dialog appears when connection is lost (app active only)
- **Connection Resilience**: Automatic reconnection with exponential backoff (max 5 attempts)
- **Network Status Banners**: Dynamic status indicators in video calls (connected/poor/reconnecting/disconnected)
- **Offline Handling**: Blocks navigation on splash screen without internet
- **Background Pause**: Connectivity monitoring pauses when app is in background

### User Experience
- **Portrait-Only Mode**: Optimized for mobile portrait orientation
- **Permission Management**: Camera and microphone permission handling
- **Splash Screen**: Smooth app initialization with connectivity checks
- **Meeting Status Indicator**: Shows if recent meetings are available to rejoin
- **Confirmation Dialogs**: End call confirmations to prevent accidental exits

### Technical Features
- **Cubit State Management**: Clean architecture with BLoC pattern
- **Repository Pattern**: Separation of data layer and business logic
- **Event Logging**: Comprehensive logging for debugging and monitoring
- **Theme System**: Centralized colors and typography (no hardcoded values)
- **Size Utils**: Responsive sizing across different screen sizes

## Architecture

### Project Structure
```
lib/
├── cubits/           # State management (Cubit)
├── repositories/     # Data layer
├── services/         # Business logic & API services
├── models/           # Data models
├── screens/          # UI screens
├── widgets/          # Reusable UI components
├── theme/            # Colors, typography, theme
└── utils/            # Utilities & constants
```

### State Management
- **Cubit Pattern**: Used for all state management
- **No setState**: Avoided for cleaner, testable code
- **Equatable**: For efficient state comparison

### Key Components

#### Cubits
- `SplashCubit`: Handles splash screen and initial navigation
- `MeetingCubit`: Manages meeting creation and joining
- `VideoCallCubit`: Controls video call state and interactions
- `PermissionCubit`: Manages camera/microphone permissions
- `ConnectivityCubit`: Monitors internet connectivity
- `MeetingStatusCubit`: Tracks recent meetings for re-join feature

#### Services
- `ChimeService`: Amazon Chime SDK integration (Android native)
- `ConnectivityService`: Internet connectivity monitoring with periodic checks
- `NetworkResilienceManager`: Connection recovery, retry logic, and state management
- `EventLogger`: Centralized logging system
- `MeetingStorageService`: Local meeting data storage

#### Widgets
- `NoInternetBottomSheet`: Modal dialog for connectivity loss (only when app is active)
- `ReconnectionBanner`: Dynamic network status indicator in video calls
- `ConnectivityWrapper`: App-wide connectivity monitoring with lifecycle awareness

#### Repositories
- `MeetingRepository`: Meeting API interactions
- Handles agent/client meeting creation and joining

## Amazon Chime Integration

### Android Native Implementation
- **Platform Channel**: `com.connectly/chime`
- **Video Views**: Native Android video rendering
- **Attendee Tracking**: Real-time participant presence detection
- **Callbacks**: Video tile events, connection events, attendee events

### Supported Features
- Audio/Video start/stop
- Camera switching
- Audio mute/unmute
- Video tile management
- Attendee presence tracking
- Connection quality monitoring

## Meeting Flow

### Agent Flow
1. Open app → Permissions → Meeting screen
2. Click "Start New Meeting"
3. Meeting created → Copy meeting details
4. Share details with client
5. Click "Start Call" → Enter video call
6. Wait for client to join

### Client Flow
1. Open app → Permissions → Meeting screen
2. Receive meeting details from agent
3. Paste details in "Join Meeting" field
4. Click "Join Meeting"
5. Meeting validated → Click "Start Call"
6. Enter video call → Connect with agent

### Re-join Flow
1. Both participants join a meeting
2. One participant leaves
3. Meeting status indicator appears (green dot)
4. Click "Re-join" button
5. Rejoin the same meeting instantly

## Design System

### Colors (AppColors)
- Centralized color palette
- Dark theme optimized
- Status colors for network states
- No hardcoded color values

### Typography (AppTypography)
- Method-based text styles
- Inter font family
- Consistent sizing and weights
- Optional parameters for customization

### Sizing (SizeUtils)
- Responsive sizing utilities
- Screen-aware dimensions
- Consistent spacing

## Network Resilience

### Connectivity Monitoring
- **Check Interval**: Every 3 seconds during active app usage
- **Socket Timeout**: 5 seconds per connectivity check
- **Debounce**: 1 second delay before showing "No Internet" dialog
- **Background Behavior**: Monitoring pauses when app goes to background
- **Resume Grace Period**: 3.5 second delay when returning from background to avoid false positives

### No Internet Bottom Sheet
- **Trigger**: Appears when internet connection is lost (app must be active)
- **Auto-dismiss**: Closes automatically when connection is restored
- **Lifecycle Aware**: Dismissed when app goes to background
- **Single Instance**: Prevents duplicate dialogs

### Connection States (Video Calls)
- `connected`: Normal operation (green indicator)
- `poor`: Degraded connection quality (orange indicator)
- `reconnecting`: Attempting to reconnect (orange indicator)
- `disconnected`: Connection lost (red indicator)

### NetworkResilienceManager
Handles connection recovery during video calls with intelligent retry logic:

#### Retry Strategy
- **Exponential Backoff**: 1s → 2s → 4s → 8s → 16s → 30s (max)
- **Maximum Attempts**: 5 retry attempts before giving up
- **Jitter**: Random delay (±20%) to prevent thundering herd
- **Stale Session Timeout**: 60 seconds without connection marks session as stale

#### State Management
- Tracks connection state changes
- Broadcasts state updates via stream
- Prevents duplicate disconnect events
- Logs all network events with metadata
- Automatic recovery on connection restore

#### Integration
- Listens to Chime SDK callbacks (`onConnectionBecamePoor`, `onConnectionRecovered`, `onAudioSessionDropped`)
- Periodic connectivity checks every 5 seconds during video calls
- Updates video call UI with real-time connection status

## Dependencies

### Core
- `flutter_bloc: ^8.1.6` - State management
- `equatable: ^2.0.5` - Value equality
- `dio: ^5.4.0` - HTTP client

### Features
- `connectivity_plus: ^6.0.5` - Network monitoring
- `permission_handler: ^11.3.0` - Permission management
- `camera: ^0.11.0+2` - Camera access
- `shared_preferences: ^2.2.2` - Local storage

### UI
- `shimmer: ^3.0.0` - Loading animations
- `another_flushbar` - Toast notifications

### Development
- `pretty_dio_logger: ^1.3.1` - API logging
- `flutter_lints: ^5.0.0` - Code quality

## Configuration

### Required: Create app_constants.dart
The `lib/utils/app_constants.dart` file is excluded from Git for security reasons. Create it manually:

**File**: `lib/utils/app_constants.dart`
```dart
import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // API Configuration
  static const String baseUrl = 'YOUR_API_ENDPOINT_HERE';
  
  // User Types
  static const String userTypeAgent = 'agent';
  static const String userTypeClient = 'client';
  
  // Utility Methods
  static void getKeyboardClose(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
```

**Important**: 
- Replace `YOUR_API_ENDPOINT_HERE` with your actual API URL
- Never commit this file to version control
- Add to `.gitignore`: `lib/utils/app_constants.dart`

### API Endpoint
The base URL should point to your backend API that handles:
- Meeting creation (POST `/meetings`)
- Meeting joining (POST `/meetings/join`)
- Returns Amazon Chime meeting configuration

### Meeting Types
- `userTypeAgent`: Agent role
- `userTypeClient`: Client role

## Permissions

The app requires the following permissions to function properly:

### Android Permissions
Already configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Camera permission for video calls -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Microphone permission for audio calls -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Internet permission for API calls and video streaming -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Network state permission for connectivity monitoring -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Camera features -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

### iOS Permissions
Configure in `ios/Runner/Info.plist`:

```xml
<!-- Camera permission -->
<key>NSCameraUsageDescription</key>
<string>Connectly needs access to your camera for video calls</string>

<!-- Microphone permission -->
<key>NSMicrophoneUsageDescription</key>
<string>Connectly needs access to your microphone for audio calls</string>
```

### Runtime Permission Handling
The app uses `permission_handler` package to request permissions at runtime:
- Camera and microphone permissions are requested on the Permission Screen
- Users must grant both permissions to proceed to the Meeting Screen
- Permissions can be managed in device settings if denied

## Build & Run

### Prerequisites
- Flutter SDK (3.8.1+)
- Android Studio / Xcode
- Android SDK / iOS SDK

### Commands
```bash
# Get dependencies
flutter pub get

# Run on Android
flutter run

# Build APK
flutter build apk --release

# Build iOS (macOS only)
flutter build ios --release
```

## Platform Support

### Android ✅
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Amazon Chime SDK: Fully integrated
- Native video rendering: Implemented

### iOS ⏳
- Minimum iOS: 12.0
- Amazon Chime SDK: Not yet implemented
- See TODO section below

## Code Quality

### Standards
- No hardcoded colors (use AppColors)
- No hardcoded text styles (use AppTypography)
- No hardcoded sizes (use SizeUtils)
- No print statements (use EventLogger)
- No comments in production code
- Cubit for state management (no setState)

### Architecture Principles
- Clean separation of concerns
- Repository pattern for data access
- Service layer for business logic
- Reusable widget components
- Centralized theme management

---

## TODO - Phase 2

### 1. iOS Native Implementation
**Priority**: High  
**Status**: Not Started

#### Tasks
- [ ] Create iOS Chime plugin (Swift/Objective-C)
- [ ] Implement ChimePlugin for iOS
  - [ ] Method channel handler
  - [ ] Meeting initialization
  - [ ] Video tile management
  - [ ] Audio/video controls
  - [ ] Attendee tracking
- [ ] Create ChimeVideoViewFactory for iOS
  - [ ] UIKit video view integration
  - [ ] Video tile binding
- [ ] Test on physical iOS devices
- [ ] Handle iOS-specific permissions
- [ ] Optimize for different iPhone models
- [ ] Test on iPad (optional)

#### Technical Details
- Use `UiKitView` for video rendering
- Implement platform channel: `com.connectly/chime`
- Mirror Android implementation for consistency
- Handle iOS lifecycle events
- Implement background mode handling

---

### 2. Enhanced Re-join Functionality
**Priority**: Medium  
**Status**: Partially Implemented

#### Current Implementation
- ✅ Stores meeting info when leaving
- ✅ Shows re-join button for 30 minutes
- ✅ Only shows if both participants joined
- ✅ Green dot indicator for available meetings

#### Remaining Tasks
- [ ] Real-time attendee presence checking
  - [ ] Implement periodic `getAttendees()` calls
  - [ ] Show actual attendee count
  - [ ] Distinguish between "active" and "empty" meetings
  - [ ] Update dot color based on presence (green = active, gray = empty)
- [ ] Backend integration for persistent presence
  - [ ] API endpoint to track active meetings
  - [ ] Heartbeat mechanism for attendee status
  - [ ] Query meeting status before rejoining
- [ ] Enhanced UI feedback
  - [ ] Show participant names in indicator
  - [ ] Display "last seen" timestamp
  - [ ] Add loading state when checking presence
- [ ] Auto-clear old meetings
  - [ ] Remove meetings older than 30 minutes
  - [ ] Clean up on app restart
- [ ] Handle edge cases
  - [ ] Meeting ended by all participants
  - [ ] Network issues during presence check
  - [ ] Concurrent rejoin attempts

#### Technical Approach
```dart
// Option 1: Periodic checking (current approach)
// - Join meeting silently
// - Call getAttendees()
// - Leave immediately
// - Update UI based on count

// Option 2: Backend API (recommended)
// - POST /meetings/{id}/heartbeat (every 10s)
// - GET /meetings/{id}/status
// - Returns: { active: true, attendeeCount: 2 }
```

---

## Future Enhancements

### Features
- [ ] Screen sharing
- [ ] Chat messaging
- [ ] Meeting recording
- [ ] Virtual backgrounds
- [ ] Noise cancellation
- [ ] Meeting history
- [ ] Contact list
- [ ] Calendar integration
- [ ] Push notifications

### Technical
- [ ] Unit tests
- [ ] Integration tests
- [ ] Widget tests
- [ ] CI/CD pipeline
- [ ] Crash reporting (Firebase Crashlytics)
- [ ] Analytics (Firebase Analytics)
- [ ] Performance monitoring

---

## License

Proprietary - All rights reserved

## Support

For issues and questions, contact the development team.
