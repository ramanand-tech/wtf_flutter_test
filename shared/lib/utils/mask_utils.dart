/// Mask secrets for DevPanel display.
String maskUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return '[invalid-url]';
  final port = uri.hasPort ? ':${uri.port}' : '';
  return '${uri.scheme}://${uri.host}$port/***';
}

String maskId(String value, {int visibleEnds = 4}) {
  if (value.isEmpty) return '—';
  if (value.startsWith('your_') || value.contains('placeholder')) {
    return '(not configured)';
  }
  if (value.length <= visibleEnds * 2) return '****';
  return '${value.substring(0, visibleEnds)}…${value.substring(value.length - visibleEnds)}';
}
