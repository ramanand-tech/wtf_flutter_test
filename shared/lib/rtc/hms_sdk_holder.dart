import 'package:hmssdk_flutter/hmssdk_flutter.dart';

/// Single HMSSDK instance per app process (preview → join lifecycle).
class HmsSdkHolder {
  HmsSdkHolder._();
  static final HmsSdkHolder instance = HmsSdkHolder._();

  HMSSDK? _sdk;
  bool _built = false;

  HMSSDK get sdk {
    _sdk ??= HMSSDK();
    return _sdk!;
  }

  Future<void> ensureBuilt() async {
    if (_built) return;
    await sdk.build();
    _built = true;
  }

  Future<void> reset() async {
    final sdk = _sdk;
    if (sdk != null) {
      try {
        await sdk.leave();
      } catch (_) {}
    }
    _sdk = null;
    _built = false;
  }
}
