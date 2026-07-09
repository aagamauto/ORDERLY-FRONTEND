# Push Notifications (FCM) — Activation Guide

Notifications are **fully coded on the backend** (`notifications.py`, `/User/Me/DeviceToken`)
and stay a **safe no-op until you finish the steps below**. Nothing here is wired into
the Flutter build yet, on purpose — adding Firebase without a `google-services.json`
would break the Android build. Follow these steps when you're ready. **All free.**

What it enables:
- New order placed → **Employee/Admin** get a push.
- Salesman edits an order → **Employee/Admin** get a push to re-check.
- Order dispatched → the **salesman** who took it gets a push.

---

## 1. Create the Firebase project (free)
1. Go to <https://console.firebase.google.com> → **Add project**.
2. Add an **Android app**. Package name: **`com.aagam.aagam_order`**
   (must match `applicationId` in `android/app/build.gradle.kts`).
3. Download **`google-services.json`** → place it in **`android/app/google-services.json`**.

## 2. Android Gradle wiring
In **`android/settings.gradle.kts`**, add the Google Services plugin to the `plugins { }` block:
```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```
In **`android/app/build.gradle.kts`**, add to the `plugins { }` block:
```kotlin
id("com.google.gms.google-services")
```

## 3. Flutter packages
Add to `pubspec.yaml` dependencies, then `flutter pub get`:
```yaml
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
```

## 4. Add the notification service
Create **`lib/services/notification_service.dart`** with:

```dart
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  // System displays background notifications automatically.
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> init() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_bgHandler);
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.onTokenRefresh.listen(_register);
  }

  /// Call AFTER a successful login (token already in secure storage).
  Future<void> registerToken() async =>
      _register(await FirebaseMessaging.instance.getToken());

  Future<void> _register(String? token) async {
    if (token == null) return;
    try {
      await DioClient.instance.dio
          .post('/User/Me/DeviceToken', data: {'token': token});
    } on DioException catch (e) {
      debugPrint('FCM register failed: $e');
    }
  }

  /// Call on logout, BEFORE clearing secure storage.
  Future<void> unregisterToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await DioClient.instance.dio
            .delete('/User/Me/DeviceToken', data: {'token': token});
      }
    } catch (_) {}
  }
}
```

## 5. Wire it in
**`lib/main.dart`** — in `main()` after `OfflineQueue.instance.init();`:
```dart
  await NotificationService.instance.init();
```
**`lib/providers/auth_provider.dart`** — at the end of a successful `login()`
(after the `state = AsyncData(...)` line):
```dart
  await NotificationService.instance.registerToken();
```
And in `logout()`, **before** `_clearStorage()`:
```dart
  await NotificationService.instance.unregisterToken();
```

## 6. Backend credentials (Render)
1. Firebase console → **Project settings → Service accounts → Generate new private key**.
2. On Render, add an env var **`FCM_CREDENTIALS_JSON`** = the full JSON contents.
3. Redeploy. `notifications.py` picks it up automatically (until then it's a no-op).

That's it — once `google-services.json` and `FCM_CREDENTIALS_JSON` are in place, pushes flow.
