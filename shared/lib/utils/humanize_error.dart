/// Maps raw exceptions / API text to reviewer-friendly copy.
String humanizeError(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('socketexception') ||
      lower.contains('connection refused') ||
      lower.contains('failed host lookup') ||
      lower.contains('network is unreachable')) {
    return 'Cannot reach the server. Start token_server (npm start) and check your network.';
  }
  if (lower.contains('timeout')) {
    return 'Request timed out. Check token_server and emulator network (10.0.2.2:3000 on Android).';
  }
  if (lower.contains('401') || lower.contains('unauthorized')) {
    return 'Video credentials rejected. Check HMS_APP_ACCESS_KEY and HMS_APP_SECRET in token_server/.env.';
  }
  if (lower.contains('permission')) {
    return 'Camera or microphone permission is required for video calls.';
  }
  if (lower.contains('conflict') || lower.contains('slot')) {
    return raw;
  }
  if (raw.length > 120) {
    return '${raw.substring(0, 117)}…';
  }
  return raw;
}
