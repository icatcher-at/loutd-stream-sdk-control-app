import 'dart:core';

String? extractFromUri(Uri uri, String key) {
  final String stringUri = uri.toString();
  if (!stringUri.contains(key))
    return null;

  final Map<String, String> queryMap = uri.queryParameters;
  return queryMap[key];
}

String generateUri(String authority, String unencodedPath,
    Map<String, dynamic> queryParameters) {
  late Uri url;
  try {
    url = Uri.http(authority, unencodedPath, queryParameters);
  } catch (e) {
    url = Uri();
    rethrow;
  }
  return url.toString();
}
