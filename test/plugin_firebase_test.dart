import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_firebase/plugin_firebase.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPluginFirebasePlatform with MockPlatformInterfaceMixin {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {}
