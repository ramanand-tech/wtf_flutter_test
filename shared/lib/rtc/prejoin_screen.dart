import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../utils/app_logger.dart';
import '../utils/app_snackbar.dart';
import '../utils/perf_tracker.dart';
import '../utils/theme.dart';
import '../widgets/app_buttons.dart';
import 'hms_sdk_holder.dart';
import 'join_call_args.dart';
import 'meeting_screen.dart';
import 'rtc_permissions.dart';
import 'rtc_token_service.dart';

class PreJoinScreen extends StatefulWidget {
  const PreJoinScreen({super.key, required this.args});

  final JoinCallArgs args;

  @override
  State<PreJoinScreen> createState() => _PreJoinScreenState();
}

class _PreJoinScreenState extends State<PreJoinScreen> implements HMSPreviewListener {
  final _tokenService = RtcTokenService();
  bool _loading = true;
  String? _error;
  String? _authToken;
  HMSVideoTrack? _previewVideo;
  bool _micOn = true;
  bool _camOn = true;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final granted = await RtcPermissions.requestCallPermissions();
    if (!granted) {
      setState(() {
        _loading = false;
        _error = 'Camera and microphone permissions are required.';
      });
      return;
    }
    try {
      final token = await _tokenService.fetchToken(
        userId: widget.args.currentUserId,
        role: widget.args.hmsRole,
        roomId: widget.args.roomId,
      );
      _authToken = token.token;
      final sdk = HmsSdkHolder.instance.sdk;
      await HmsSdkHolder.instance.ensureBuilt();
      sdk.addPreviewListener(listener: this);
      final config = HMSConfig(
        authToken: token.token,
        userName: widget.args.userName,
      );
      await sdk.preview(config: config);
    } on RtcTokenException catch (e) {
      AppLogger.instance.log(LogTag.rtc, 'Token error: $e');
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      AppLogger.instance.log(LogTag.rtc, 'Prejoin error: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleMic() async {
    await HmsSdkHolder.instance.sdk.toggleMicMuteState();
    setState(() => _micOn = !_micOn);
  }

  Future<void> _toggleCam() async {
    await HmsSdkHolder.instance.sdk.toggleCameraMuteState();
    setState(() => _camOn = !_camOn);
  }

  void _joinMeeting() {
    if (_authToken == null) return;
    PerfTracker.mark(PerfMarks.rtcRoomJoin);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => MeetingScreen(
          args: widget.args,
          authToken: _authToken!,
        ),
      ),
    );
  }

  @override
  void onHMSError({required HMSException error}) {
    setState(() {
      _error = error.message ?? 'Preview error';
      _loading = false;
    });
  }

  @override
  void onPreview({required HMSRoom room, required List<HMSTrack> localTracks}) {
    HMSVideoTrack? video;
    for (final t in localTracks) {
      if (t.kind == HMSTrackKind.kHMSTrackKindVideo) {
        video = t as HMSVideoTrack;
        break;
      }
    }
    setState(() {
      _previewVideo = video;
      _loading = false;
    });
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-join')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ready to join? Check mic and camera.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_error!, textAlign: TextAlign.center),
                                  const SizedBox(height: 16),
                                  AppSecondaryButton(
                                    label: 'Retry',
                                    onPressed: () {
                                      setState(() {
                                        _loading = true;
                                        _error = null;
                                      });
                                      _setup();
                                    },
                                  ),
                                  AppTertiaryButton(
                                    label: 'Copy error',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: _error!));
                                      AppSnackbar.showInfo(context, 'Error details copied');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _previewVideo != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: HMSVideoView(
                                  track: _previewVideo!,
                                  scaleType: ScaleType.SCALE_ASPECT_FILL,
                                ),
                              )
                            : const Center(child: Text('Camera starting…')),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: _error == null ? _toggleMic : null,
                  icon: Icon(_micOn ? Icons.mic : Icons.mic_off),
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  onPressed: _error == null ? _toggleCam : null,
                  icon: Icon(_camOn ? Icons.videocam : Icons.videocam_off),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _error == null && !_loading ? _joinMeeting : null,
              style: FilledButton.styleFrom(backgroundColor: widget.args.primaryColor),
              child: const Text('Join Call'),
            ),
          ],
        ),
      ),
    );
  }
}
