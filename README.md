# call_info_app

Flutter + Android native proof-of-concept for showing caller-related information inside the app
experience without using system-wide overlays. It listens for call state changes, raises a
notification that deep-links into Flutter, and shows caller details from a local database with an
API fallback.

## ✅ Play policy-friendly behavior

- No overlays (`SYSTEM_ALERT_WINDOW` removed).
- Call log access is **optional** and only used if the user explicitly grants it.
- Only minimal permissions: `READ_PHONE_STATE` (optional) and `POST_NOTIFICATIONS`.
- If permissions are denied or numbers are unavailable, the app falls back to manual lookup.
- Call detection is handled by a manifest-registered receiver so notifications can still be posted
  even if the app process is killed.

## Project structure

- `lib/` – Flutter UI, repository pattern, Sqflite DB, and call event streams.
- `android/` – Kotlin receiver + notification + Flutter channel integration.

## Implementation sequence (breakdown)

1. **Detect call events** via `PhoneCallReceiver` and confirm call state delivery to Flutter.
2. **Resolve the phone number** and match it against a mock caller list (and local DB) to
   display name/company/notes in the Caller Details screen.
3. **Deep-link from notifications** into Flutter with the number for quick lookups.
4. **Fallback to manual lookup** when the device cannot provide a number.

## Debugging missing caller numbers

If call events show **Number unavailable**, Android did not provide `EXTRA_INCOMING_NUMBER`.
There are two possible paths:

1. **Grant optional call log access** (`READ_CALL_LOG`). After the call ends, the receiver
   reads the most recent call log entry and posts the notification with that number.
2. **Manual lookup** (always available) by pasting the number into the Home screen.

Use the **Debug Log** screen to inspect which source was used:

- `extra_incoming_number` → system provided the number during ringing
- `last_known_number` → app used the last saved number
- `call_log_lookup` → app recovered the number from call log after the call ended
- `missing` → no number was available from any source

## Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
2. Ensure Android permissions are declared:
   - `READ_PHONE_STATE` for call state access
   - `POST_NOTIFICATIONS` for Android 13+
   - `READ_CALL_LOG` (optional) to read the latest call log entry if the system does not provide
     numbers via `EXTRA_INCOMING_NUMBER`
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
