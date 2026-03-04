# Medicine Intake (Flutter / Android)

A Flutter starter app based on the 25-day taper schedule shown in your leaflet image.

## What this app does
- Tracks treatment for 25 days with progressively reduced intake frequency.
- Lets you set patient name and treatment start date.
- Lets you mark each day doses as completed.
- Persists state locally using `shared_preferences`.

## Run
```bash
flutter pub get
flutter run -d android
```

## Notes
- Current schedule was transcribed from the photo and labels are in English.
- For production reminders, add `flutter_local_notifications` and schedule alerts.
