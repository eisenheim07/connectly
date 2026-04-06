# Manual Testing Guide - Full API Response Method

## ✅ Super Easy Testing!

Just paste the ENTIRE API response - the app extracts everything automatically!

## Steps to Test

### Device 1 (Create Meeting):

1. Open app
2. Click "Start New Meeting"
3. **Copy the ENTIRE API response from logs** (see below)
4. Share via WhatsApp to Device 2

### Device 2 (Join Meeting):

1. Open app
2. In "Join a Meeting" section:
   - **Paste the entire API response** in the text field
3. Click "Join Meeting"
4. Video call starts! ✅

## What to Copy

Copy the ENTIRE response like this:

```json
{"status": "success","message": "Meeting created successfully","data": {"meeting": {"MeetingId": "c1aa49fe-890e-4c4d-b7df-0d95d6b42954","ExternalMeetingId": "0899","MediaRegion": "ap-southeast-1","MediaPlacement": {"AudioHostUrl": "d14e94c33dfa3de2881a93dbe06426c2.k.m1.as1.app.chime.aws:3478","AudioFallbackUrl": "wss://wss.k.m1.as1.app.chime.aws:443/calls/c1aa49fe-890e-4c4d-b7df-0d95d6b42954","SignalingUrl": "wss://signal.m1.as1.app.chime.aws/control/c1aa49fe-890e-4c4d-b7df-0d95d6b42954","TurnControlUrl": "https://2954.cell.ap-southeast-1.meetings.chime.aws/v2/turn_sessions","ScreenDataUrl": "wss://bitpw.m1.as1.app.chime.aws:443/v2/screen/c1aa49fe-890e-4c4d-b7df-0d95d6b42954","ScreenViewingUrl": "wss://bitpw.m1.as1.app.chime.aws:443/ws/connect?passcode=null&viewer_uuid=null&X-BitHub-Call-Id=c1aa49fe-890e-4c4d-b7df-0d95d6b42954","ScreenSharingUrl": "wss://bitpw.m1.as1.app.chime.aws:443/v2/screen/c1aa49fe-890e-4c4d-b7df-0d95d6b42954","EventIngestionUrl": "https://data.svc.as1.ingest.chime.aws/v1/client-events"},"MeetingFeatures": {"Audio": {"EchoReduction": "UNAVAILABLE"}},"TenantIds": [],"MeetingArn": "arn:aws:chime:ap-southeast-1:587953674438:meeting/c1aa49fe-890e-4c4d-b7df-0d95d6b42954"},"attendee": {"ExternalUserId": "agent","AttendeeId": "16a94227-b55f-e07b-dc33-9d3629f33d1f","JoinToken": "MTZhOTQyMjctYjU1Zi1lMDdiLWRjMzMtOWQzNjI5ZjMzZDFmOmQ3N2YzZjBhLTdmNTMtNDY5MC1hZmFiLTk5ZGVjZjgzNmYwYQ","Capabilities": {"Audio": "SendReceive","Video": "SendReceive","Content": "SendReceive"}}}}
```

## How to Get API Response

### From Android Logs:

```bash
adb logcat | grep "Meeting created successfully"
```

Or look for the full response in your Flutter logs.

### From App Logs:

When Device 1 creates a meeting, look for the API response in the console/logcat.

## What the App Does Automatically

The app will:
1. ✅ Extract Meeting ID
2. ✅ Extract MediaRegion
3. ✅ Extract MediaPlacement (all URLs)
4. ✅ Get client token from API
5. ✅ Join the meeting

## Example Flow

### Device 1:
```
1. Create meeting
2. Copy entire API response from logs
3. Send to Device 2 via WhatsApp
```

### Device 2:
```
1. Paste entire API response
2. Click "Join Meeting"
3. Connected! ✅
```

## Benefits

✅ Super easy - just one paste!
✅ No manual extraction needed
✅ Works cross-device immediately
✅ No Firebase setup needed
✅ Perfect for testing

## Troubleshooting

### "Invalid API response format"
- Make sure you copied the ENTIRE response
- Should start with `{"status": "success"`
- Should include both `meeting` and `attendee` objects

### "Meeting not found"
- Make sure the meeting was created successfully
- Check that you copied the complete response

### Video not connecting
- Check internet connection
- Check camera/mic permissions
- Verify the MediaPlacement URLs are correct

## For Production

This is a **testing workaround**. For production, use:
- Firebase storage (see FIREBASE_SETUP.md)
- Backend storage
- QR code sharing
- Deep links
