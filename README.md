# plugin_firebase

`Android` `iOS`

Plugin helps request, show and handle the notification on Android/iOS via FCM.

## Getting started

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```yaml
dependencies:
  git:
    url: https://github.com/devemeausss/plugin_firebase
    ref: 3801d6bf728433d4fdb43c132e3ca10af4258d44
```

## How to use

### Config notification

```dart
import 'package:plugin_firebase/index.dart';

@override
void initState() {
    MyPluginNotification.settingNotification(
        colorNotification: Colors.red,
        onMessage: (RemoteMessage remoteMessage) {
            // Trigger when receive notification
        },
        onOpenLocalMessage: (String message) {
            // Trigger when the user clicks local notification
        },
        onOpenFCMMessage: (RemoteMessage remote) {
            // Trigger when the user clicks FCM notification
        },
        onRegisterFCM: (Map<String, dynamic> data) {
            // Call register FCM token to your server
        },
        iconNotification: 'icon_notification',
        chanelId: 'chanel',
        chanelName: 'app_channel',
        channelDescription: 'chanel description',
        onShowLocalNotification: (RemoteMessage message) => true,
    );
}

@override
void dispose() {
    MyPluginNotification.dispose();
    super.dispose();
}

```

### Config crashlytícs.

```dart
import 'package:plugin_firebase/index.dart';

void main() {
    MyPluginNotification.setupCrashlytics(main: () async {
        ...
    })
}
```

### Handle deeplink

```dart
import 'package:plugin_firebase/index.dart';

@override
void initState() {
    MyPluginDeepLinkWithFirebase.initDynamicLinks(
        handleDynamicLink: (uri) {
            // Handle deeplink
        },
        onError: (error) {
            // Handle error
        }
    )
}
```
