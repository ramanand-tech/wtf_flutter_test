import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared/services/app_services.dart';

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '/tmp';

  @override
  Future<String?> getTemporaryPath() async => '/tmp';
}

Future<void> initTestAppServices({required String hiveBoxName}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();
  await AppServices.init(hiveBoxName: hiveBoxName);
}
