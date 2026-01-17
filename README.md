# call_info_app

Flutter + Android native proof-of-concept for showing caller-related information inside the app
experience without using system-wide overlays. It listens for call state changes, raises a
notification that deep-links into Flutter, and shows caller details from a local database with an
API fallback.

## ✅ Play policy-friendly behavior

- No overlays (`SYSTEM_ALERT_WINDOW` removed).
- No call log access (`READ_CALL_LOG` removed).
- Only minimal permissions: `READ_PHONE_STATE` (optional) and `POST_NOTIFICATIONS`.
- If permissions are denied or numbers are unavailable, the app falls back to manual lookup.

## Project structure

- `lib/` – Flutter UI, repository pattern, Sqflite DB, and call event streams.
- `android/` – Kotlin receiver + notification + Flutter channel integration.

## Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
2. Ensure Android permissions are declared:
   - `READ_PHONE_STATE` for call state access
   - `POST_NOTIFICATIONS` for Android 13+
3. Run on an Android device/emulator:
   ```bash
   flutter run
   ```

## Android native integration

- `PhoneCallReceiver` listens to `android.intent.action.PHONE_STATE`.
- Call events are forwarded to Flutter via an `EventChannel`.
- Notifications are posted from Kotlin to open the Flutter app with extras.
- `MainActivity` forwards deep links to Flutter via `MethodChannel`.

## Testing

1. Grant Phone + Notification permissions in the app.
2. Place or receive a call on the device.
3. Tap the “Open Caller Details” notification to open the caller details screen.
4. If the number is not available, use manual lookup on the Home screen.

## Notes

- This project does not claim to be a default dialer, call screening, or spam blocking app.
- Caller number access depends on Android version, OEM behavior, and permissions.
- Update `CallerRepository` to use your backend API once available.
