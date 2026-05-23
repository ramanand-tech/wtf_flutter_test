import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../models/enums.dart';
import '../services/app_services.dart';
import '../utils/app_logger.dart';
import '../utils/app_snackbar.dart';
import '../utils/perf_tracker.dart';
import '../utils/theme.dart';
import 'hms_sdk_holder.dart';
import 'join_call_args.dart';
import 'post_call_sheets.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({
    super.key,
    required this.args,
    required this.authToken,
  });

  final JoinCallArgs args;
  final String authToken;

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> implements HMSUpdateListener {
  final _sdk = HmsSdkHolder.instance.sdk;
  bool _joined = false;
  bool _reconnecting = false;
  bool _ending = false;
  bool _micOn = true;
  bool _camOn = true;
  DateTime? _startedAt;
  String? _sessionLogId;

  final Map<String, HMSVideoTrack> _videoByPeerId = {};

  @override
  void initState() {
    super.initState();
    _joinRoom();
  }

  Future<void> _joinRoom() async {
    await HmsSdkHolder.instance.ensureBuilt();
    _sdk.addUpdateListener(listener: this);
    final config = HMSConfig(
      authToken: widget.authToken,
      userName: widget.args.userName,
    );
    await _sdk.join(config: config);
  }

  Future<void> _toggleMic() async {
    await _sdk.toggleMicMuteState();
    if (mounted) setState(() => _micOn = !_micOn);
  }

  Future<void> _toggleCam() async {
    await _sdk.toggleCameraMuteState();
    if (mounted) setState(() => _camOn = !_camOn);
  }

  void _updateVideoTrack(HMSPeer peer, HMSTrack track, HMSTrackUpdate update) {
    if (track.kind != HMSTrackKind.kHMSTrackKindVideo) return;
    final video = track as HMSVideoTrack;
    if (update == HMSTrackUpdate.trackRemoved) {
      _videoByPeerId.remove(peer.peerId);
    } else {
      _videoByPeerId[peer.peerId] = video;
    }
    setState(() {});
  }

  Future<void> _endCall() async {
    if (_ending) return;
    _ending = true;
    final started = _startedAt ?? DateTime.now();
    final ended = DateTime.now();
    try {
      await _sdk.leave();
    } catch (_) {}
    _sdk.removeUpdateListener(listener: this);
    final log = await AppServices.instance.logs.createFromCall(
      memberId: widget.args.callRequest.memberId,
      trainerId: widget.args.callRequest.trainerId,
      startedAt: started,
      endedAt: ended,
      callRequestId: widget.args.callRequest.id,
    );
    _sessionLogId = log.id;
    await AppServices.instance.logs.pullRemote();
    await HmsSdkHolder.instance.reset();
    if (!mounted) return;
    AppSnackbar.showSuccess(context, 'Session saved. Check My Sessions / Sessions.');
    await _showPostCall();
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _showPostCall() async {
    if (_sessionLogId == null) return;
    if (widget.args.currentRole == UserRole.member) {
      await showMemberPostCallSheet(
        context,
        logId: _sessionLogId!,
        primaryColor: widget.args.primaryColor,
      );
    } else {
      await showTrainerPostCallSheet(context, logId: _sessionLogId!);
    }
  }

  @override
  void onJoin({required HMSRoom room}) {
    AppLogger.instance.log(LogTag.rtc, 'Joined room ${room.id}');
    PerfTracker.report(PerfMarks.rtcRoomJoin, budgetMs: PerfBudgets.rtcJoinMs);
    setState(() {
      _joined = true;
      _startedAt = DateTime.now();
    });
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (update == HMSPeerUpdate.peerLeft) {
      _videoByPeerId.remove(peer.peerId);
      setState(() {});
    }
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    _updateVideoTrack(peer, track, trackUpdate);
  }

  @override
  void onHMSError({required HMSException error}) {
    AppLogger.instance.log(LogTag.rtc, 'HMS error: ${error.message}');
    if (!mounted) return;
    final msg = error.message ?? 'Call error';
    AppSnackbar.showError(context, msg, copyText: error.toString());
  }

  @override
  void onReconnecting() => setState(() => _reconnecting = true);

  @override
  void onReconnected() => setState(() => _reconnecting = false);

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onChangeTrackStateRequest({required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    if (!mounted || _ending) return;
    AppSnackbar.showInfo(
      context,
      'Other participant left. Tap the end button to save this session.',
    );
  }

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {}

  @override
  Widget build(BuildContext context) {
    final tiles = _videoByPeerId.entries.toList();
    final isTrainer = widget.args.currentRole == UserRole.trainer;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_joined ? 'In call' : 'Connecting…'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (!_joined)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (tiles.isEmpty)
            const Center(
              child: Text('Waiting for other participant…', style: TextStyle(color: Colors.white)),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: tiles.length == 1 ? 1 : 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: tiles.length,
                itemBuilder: (_, i) {
                  final entry = tiles[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        HMSVideoView(
                          track: entry.value,
                          scaleType: ScaleType.SCALE_ASPECT_FILL,
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: Colors.black54,
                            child: Text(
                              entry.key,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (_reconnecting)
            const ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text('Reconnecting…', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _control(
                  _micOn ? Icons.mic : Icons.mic_off,
                  _toggleMic,
                  enabled: _micOn,
                ),
                _control(
                  _camOn ? Icons.videocam : Icons.videocam_off,
                  _toggleCam,
                  enabled: _camOn,
                ),
                _control(Icons.cameraswitch, () => _sdk.switchCamera()),
                if (isTrainer)
                  _control(Icons.call_end, _endCall, color: AppColors.error),
                if (!isTrainer)
                  _control(Icons.exit_to_app, _endCall, color: AppColors.neutral700),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _control(
    IconData icon,
    VoidCallback onTap, {
    Color? color,
    bool enabled = true,
  }) {
    final bg = color ?? (enabled ? Colors.white24 : AppColors.error);
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
