import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class MyPluginFirebase {
  static Future<String> getMeIdDevice(String? currentIMEI) async {
    String meId = '';
    if (currentIMEI != null) {
      return currentIMEI;
    }

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDevice = await DeviceInfoPlugin().androidInfo;
        meId = androidDevice.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDevice = await DeviceInfoPlugin().iosInfo;
        meId = iosDevice.identifierForVendor!;
      }
    } on PlatformException {
      print('Error:' 'Failed to get platform version.');
    }
    return meId;
  }
}
